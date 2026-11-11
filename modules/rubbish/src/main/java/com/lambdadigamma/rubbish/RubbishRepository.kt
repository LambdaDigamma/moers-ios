package com.lambdadigamma.rubbish

import android.content.Context
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.lambdadigamma.core.extensions.resultOf
import com.lambdadigamma.core.utils.LastUpdate
import com.lambdadigamma.rubbish.notifications.RubbishScheduleNotificationWorker
import com.lambdadigamma.rubbish.settings.RubbishSettings
import com.lambdadigamma.rubbish.source.RubbishApi
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import java.time.Duration
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId
import java.time.ZonedDateTime
import java.util.Date
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class RubbishRepository @Inject constructor(
    @param:ApplicationContext private val context: Context,
    private val api: RubbishApi,
    private val rubbishDao: RubbishDao,
) {

    private val dataStore = context.rubbishSettingsDataStore
    private val lastStreetsUpdate = LastUpdate(key = "rubbishStreets", context = context)

    // --- Streets

    val streets: Flow<List<RubbishCollectionStreet>> = rubbishDao.observeStreets()

    /** The selected street, or `null` when the user has not chosen one yet. */
    val currentStreet: Flow<RubbishSettings.RubbishCollectionStreet?> = dataStore.data.map { settings ->
        settings.rubbishCollectionStreet.takeIf { settings.hasRubbishCollectionStreet() && it.id > 0 }
    }

    /** Loads all streets once a day. The list is used to search streets offline. */
    suspend fun refreshStreets(force: Boolean = false): Result<Unit> = resultOf {
        val lastUpdate = lastStreetsUpdate.get()
        val isFresh = lastUpdate != null &&
            Date().time - lastUpdate.time < TimeUnit.DAYS.toMillis(1) &&
            rubbishDao.countStreets() > 0
        if (force || !isFresh) {
            rubbishDao.insertStreets(api.streets().data)
            lastStreetsUpdate.set(Date())
        }
    }

    suspend fun setStreet(id: Int, name: String) {
        val street = RubbishSettings.RubbishCollectionStreet.newBuilder()
            .setId(id.toLong())
            .setName(name)
            .build()
        dataStore.updateData { it.toBuilder().setRubbishCollectionStreet(street).build() }
        rubbishDao.deleteAllCollectionItems()
        refreshPickups()
    }

    // --- Pickups

    /** Pickups from today on, ordered by date. */
    val upcomingPickups: Flow<List<RubbishCollectionItem>> = rubbishDao.observeCollectionItems().map { items ->
        val today = LocalDate.now()
        items.filter { item -> item.localDate?.isBefore(today) == false }
    }

    /** Loads the pickups of the selected street and updates the reminders. */
    suspend fun refreshPickups(): Result<Unit> = resultOf {
        val street = currentStreet.first()
        val items = if (street == null) emptyList() else api.pickups(street.id).data
        rubbishDao.replaceCollectionItems(items.map { it.copy(id = 0) })
        rescheduleReminders()
    }

    // --- Reminders

    val reminderEnabled: Flow<Boolean> = dataStore.data.map { it.remindersEnabled }

    val reminderTime: Flow<RubbishSettings.RubbishReminderTime?> = dataStore.data.map { settings ->
        settings.reminderTime.takeIf { settings.hasReminderTime() }
    }

    suspend fun setRemindersEnabled(enabled: Boolean) {
        dataStore.updateData { it.toBuilder().setRemindersEnabled(enabled).build() }
        rescheduleReminders()
    }

    suspend fun setReminderTime(hours: Int, minutes: Int) {
        val time = RubbishSettings.RubbishReminderTime.newBuilder()
            .setHours(hours)
            .setMinutes(minutes)
            .build()
        dataStore.updateData { it.toBuilder().setReminderTime(time).build() }
        rescheduleReminders()
    }

    /**
     * Schedules one notification on the evening before each upcoming pickup day.
     * Only the reminder work of this feature is replaced; other WorkManager jobs are kept.
     */
    suspend fun rescheduleReminders() {
        val workManager = WorkManager.getInstance(context)
        workManager.cancelAllWorkByTag(RubbishScheduleNotificationWorker.TAG)

        val settings = dataStore.data.first()
        if (!settings.remindersEnabled || currentStreet.first() == null) return

        val time = settings.reminderTime.takeIf { settings.hasReminderTime() }
        val reminders = reminderSchedule(
            items = rubbishDao.collectionItems(),
            reminderTime = LocalTime.of(time?.hours ?: DEFAULT_REMINDER_HOUR, time?.minutes ?: 0),
            now = ZonedDateTime.now(),
        )

        for (reminder in reminders) {
            val request = OneTimeWorkRequestBuilder<RubbishScheduleNotificationWorker>()
                .setInitialDelay(reminder.delay.toMillis(), TimeUnit.MILLISECONDS)
                .setInputData(RubbishScheduleNotificationWorker.inputData(reminder.types))
                .addTag(RubbishScheduleNotificationWorker.TAG)
                .build()
            workManager.enqueueUniqueWork(
                "${RubbishScheduleNotificationWorker.TAG}-${reminder.pickupDay}",
                ExistingWorkPolicy.REPLACE,
                request,
            )
        }
    }

    data class Reminder(val pickupDay: LocalDate, val types: List<RubbishWasteType>, val delay: Duration)

    companion object {
        const val DEFAULT_REMINDER_HOUR = 20

        /** One reminder per pickup day at [reminderTime] on the day before, if that is still ahead. */
        fun reminderSchedule(
            items: List<RubbishCollectionItem>,
            reminderTime: LocalTime,
            now: ZonedDateTime,
            zone: ZoneId = now.zone,
        ): List<Reminder> = items
            .mapNotNull { item -> item.localDate?.let { it to item.type } }
            .groupBy({ it.first }, { it.second })
            .toSortedMap()
            .mapNotNull { (day, types) ->
                val remindAt = day.minusDays(1).atTime(reminderTime).atZone(zone)
                val delay = Duration.between(now, remindAt)
                if (delay.isNegative) null else Reminder(day, types.distinct(), delay)
            }
    }
}
