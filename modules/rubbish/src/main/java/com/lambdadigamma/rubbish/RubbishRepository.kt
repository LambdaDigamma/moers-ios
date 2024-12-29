package com.lambdadigamma.rubbish

import android.app.NotificationManager
import android.content.Context
import android.util.Log
import androidx.datastore.core.DataStore
import androidx.lifecycle.LiveData
import androidx.lifecycle.map
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.lambdadigamma.core.AppExecutors
import com.lambdadigamma.core.NetworkBoundResource
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.notifications.milliInterval
import com.lambdadigamma.core.toResource
import com.lambdadigamma.core.utils.LastUpdate
import com.lambdadigamma.core.utils.minuteInterval
import com.lambdadigamma.rubbish.notifications.RubbishScheduleNotificationWorker
import com.lambdadigamma.rubbish.settings.RubbishSettings
import com.lambdadigamma.rubbish.source.RubbishApi
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import java.util.*
import java.util.concurrent.TimeUnit
import javax.inject.Inject

class RubbishRepository @Inject constructor(
    @ApplicationContext private val context: Context,
//    private val locationService: LocationService,
//    private val remoteDataSource: RubbishRemoteDataSource,
    val remoteDataSource: RubbishApi,
    private val rubbishDao: RubbishDao,
    private val appExecutors: AppExecutors // = AppExecutors()
) {

    private val notificationManager =
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private val dataStore: DataStore<RubbishSettings> = context.rubbishSettingsDataStore

    private val lastUpdate = LastUpdate(key = "rubbishStreets", context = context)
    private val lastUpdateCollectionItems =
        LastUpdate(key = "rubbishCollectionItems", context = context)

    fun getRubbishStreets(streetName: String? = null): LiveData<Resource<List<RubbishCollectionStreet>?>> {
        return object :
            NetworkBoundResource<List<RubbishCollectionStreet>, List<RubbishCollectionStreet>>(
                appExecutors
            ) {

            override fun saveCallResult(item: List<RubbishCollectionStreet>) {
                rubbishDao.insertRubbishStreets(item)
                lastUpdate.set(lastUpdate = Date())
            }

            override fun shouldFetch(data: List<RubbishCollectionStreet>?): Boolean {

                if (data == null || data.orEmpty().isEmpty()) {
                    Log.d("RubbishRepository", "Should fetch: data is null or empty")

                    return true
                }

                val shouldLoad = (lastUpdate.get()?.minuteInterval() ?: 120) > 60

                Log.d(
                    "RubbishRepository",
                    "Checking last update interval for rubbish streets. Should reload: $shouldLoad"
                )
                return shouldLoad
            }

            override fun loadFromDb(): LiveData<List<RubbishCollectionStreet>> {

                streetName?.let {
                    return rubbishDao.getRubbishStreet(streetName = it)
                }

                return rubbishDao.getRubbishStreets()
            }

            override fun createCall(): LiveData<Resource<List<RubbishCollectionStreet>>> {

                Log.d("API", "Fetching streets")

                val fetchedStreets = remoteDataSource.fetchStreets(streetName = streetName)

                return fetchedStreets.map { data ->
                    return@map data.transform { it.data }
                }
            }

        }.asLiveData()
    }

    suspend fun loadRubbishCollectionItemsSuspended(): Flow<Resource<List<RubbishCollectionItem>>> {

        return flow {
            emit(Resource.loading())

            dataStore.data.map { it.rubbishCollectionStreet.id }
                .first()
                .let { streetId ->
                    val fetchedItems =
                        remoteDataSource.getPickupItems(streetId = streetId)
                            .toResource()
                            .transform { response ->
                                response.data
                            }

                    updateLocalStore(fetchedItems)

                    emit(fetchedItems)
                }

        }

    }

//    fun loadRubbishCollectionItems(): LiveData<Resource<List<RubbishCollectionItem>?>> {
//
//        return object :
//            NetworkBoundResource<List<RubbishCollectionItem>, List<RubbishCollectionItem>>(
//                appExecutors
//            ) {
//
//            override fun saveCallResult(item: List<RubbishCollectionItem>) {
//                rubbishDao.deleteAllRubbishCollectionItems()
//                rubbishDao.insertRubbishCollectionItems(item)
//                removeAllRubbishNotifications()
//
//                appExecutors.diskIO().execute(Runnable {
//                    runBlocking {
//                        val time = reminderTime.first()
//                        scheduleNotifications(
//                            collectionItems = item,
//                            hours = time?.hours ?: 20,
//                            minutes = time?.minutes ?: 0,
//                        )
//                    }
//                })
//
//                lastUpdateCollectionItems.set(lastUpdate = Date())
//            }
//
//            override fun shouldFetch(data: List<RubbishCollectionItem>?): Boolean {
//                if (data == null || data.orEmpty().isEmpty()) {
//                    return true
//                }
//
//                return (lastUpdateCollectionItems.get()?.minuteInterval() ?: 120) > 60
//            }
//
//            override fun loadFromDb(): LiveData<List<RubbishCollectionItem>> {
//                Log.d("Api", "Loading items from db")
//                return rubbishDao.loadAllRubbishCollectionItems()
//            }
//
//            override fun createCall(): LiveData<Resource<List<RubbishCollectionItem>>> {
//
//                return Transformations.switchMap(dataStore.data.asLiveData()) {
//                    Log.d("Api", it.rubbishCollectionStreet.id.toString())
//                    Transformations.map(remoteDataSource.getPickupItems(it.rubbishCollectionStreet.id)) { resource ->
//                        Log.d("Api", resource.toString())
//                        Resource.success(resource.data?.data.orEmpty())
//                    }
//                }
//            }
//        }.asLiveData()
//
//    }

    private suspend fun updateLocalStore(resource: Resource<List<RubbishCollectionItem>>) {

        if (!resource.isSuccessful()) {
            return
        }

        val items = resource.data.orEmpty()

        withContext(Dispatchers.IO) {
            rubbishDao.deleteAllRubbishCollectionItems()
            rubbishDao.insertRubbishCollectionItems(items)
            removeAllRubbishNotifications()
        }

        withContext(Dispatchers.IO) {
            val time = reminderTime.first()
            scheduleNotifications(
                collectionItems = items,
                hours = time?.hours ?: 20,
                minutes = time?.minutes ?: 0,
            )
        }

//        appExecutors.diskIO().execute(Runnable {
//            runBlocking {
//                val time = reminderTime.first()
//                scheduleNotifications(
//                    collectionItems = item,
//                    hours = time?.hours ?: 20,
//                    minutes = time?.minutes ?: 0,
//                )
//            }
//        })

        lastUpdateCollectionItems.set(lastUpdate = Date())

    }

    // --- Reminder

    val reminderEnabled: Flow<Boolean> = dataStore.data
        .map { settings ->
            settings.remindersEnabled
        }

    val reminderTime: Flow<RubbishSettings.RubbishReminderTime?> = dataStore.data
        .map { settings ->
            if (settings.hasReminderTime()) {
                return@map settings.reminderTime
            } else {
                return@map null
            }
        }

    suspend fun enableReminders(hours: Int = 20, minutes: Int = 0) {
        context.rubbishSettingsDataStore.updateData { settings ->
            settings.toBuilder()
                .setRemindersEnabled(true)
                .setReminderTime(
                    RubbishSettings.RubbishReminderTime
                        .newBuilder()
                        .setHours(hours)
                        .setMinutes(minutes)
                )
                .build()
        }
    }

    suspend fun disableReminders() {
        context.rubbishSettingsDataStore.updateData { settings ->
            settings.toBuilder()
                .setRemindersEnabled(false)
                .build()
        }
    }

    suspend fun setStreet(id: Int, name: String) {
        val rubbishSettingsStreet = RubbishSettings.RubbishCollectionStreet
            .newBuilder()
            .setId(id.toLong())
            .setName(name)
            .build()

        dataStore.updateData { settings ->
            settings.toBuilder()
                .setRubbishCollectionStreet(rubbishSettingsStreet)
                .build()
        }
    }

    val currentStreet: Flow<RubbishSettings.RubbishCollectionStreet> = dataStore.data
        .map { settings ->
            settings.rubbishCollectionStreet
        }

    suspend fun changeReminderTime(hours: Int, minutes: Int) {
//        context.rubbishSettingsDataStore
    }

    // --- Notifications ---

    fun scheduleNotifications(
        collectionItems: List<RubbishCollectionItem>,
        hours: Int,
        minutes: Int
    ) {

        val workManager: WorkManager = WorkManager.getInstance(context)

        for (item in collectionItems.filter { it.parsedDate > Date() }) {

            val reminderDate = getDateOfPreviousDayAtHourMinute(
                date = item.parsedDate,
                hour = hours,
                minutes = minutes
            )

            val delay = Date().milliInterval(reminderDate)

            val work =
                OneTimeWorkRequestBuilder<RubbishScheduleNotificationWorker>()
                    .setInitialDelay(delay, TimeUnit.MILLISECONDS)
                    .setInputData(RubbishScheduleNotificationWorker.inputData(item.type))
                    .addTag(RubbishScheduleNotificationWorker.TAG)
                    .build()

            workManager.enqueue(work)

        }

    }

    private fun scheduleTestNotification() {

        val workManager: WorkManager = WorkManager.getInstance(context)

        val work =
            OneTimeWorkRequestBuilder<RubbishScheduleNotificationWorker>()
                .setInitialDelay(10, TimeUnit.SECONDS)
                .setInputData(RubbishScheduleNotificationWorker.inputData(RubbishWasteType.ORGANIC))
                .addTag(RubbishScheduleNotificationWorker.TAG)
                .build()

        workManager.enqueue(work)

    }

    private fun getDateOfPreviousDayAtHourMinute(date: Date, hour: Int, minutes: Int): Date {
        val calendar = Calendar.getInstance()
        calendar.time = date
        calendar.set(Calendar.HOUR_OF_DAY, hour)
        calendar.set(Calendar.MINUTE, minutes)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        calendar.add(Calendar.DATE, -1)
        return calendar.time
    }

    fun removeAllRubbishNotifications() {
        val workManager: WorkManager = WorkManager.getInstance(context)
        workManager.cancelAllWork()
        workManager.cancelAllWorkByTag("rubbish_schedule_notification")
    }

}