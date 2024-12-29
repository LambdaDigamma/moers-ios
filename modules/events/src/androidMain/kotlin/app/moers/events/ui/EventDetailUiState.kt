package com.lambdadigamma.events.ui

import androidx.annotation.StringRes
import com.lambdadigamma.core.ui.Venue
import com.lambdadigamma.events.R
import com.lambdadigamma.events.models.Event
import java.text.SimpleDateFormat
import java.util.*

const val eventActiveMinuteThreshold = 30

const val ATTENDANCE_MIXED = "mixed";
const val ATTENDANCE_OFFLINE = "offline";
const val ATTENDANCE_ONLINE = "online";

data class TimeComponent(
    val day: String,
    val date: String,
    val startTime: String,
    val endTime: String
)

enum class EventAttendanceMode(val value: String) {
    MIXED(ATTENDANCE_MIXED),
    OFFLINE(ATTENDANCE_OFFLINE),
    ONLINE(ATTENDANCE_ONLINE),
}

@StringRes
fun EventAttendanceMode.localizedName(): Int {
    return when (this) {
        EventAttendanceMode.MIXED -> R.string.attendance_mode_mixed
        EventAttendanceMode.OFFLINE -> R.string.attendance_mode_offline
        EventAttendanceMode.ONLINE -> R.string.attendance_mode_online
    }
}

val defaultAttendanceMode = EventAttendanceMode.OFFLINE

data class EventDetailUiState(
    val id: Int,
    val name: String,
    val description: String?,
    val date: String,
    val venue: Venue? = null,
    val organizer: String? = null,
    val isLive: Boolean = false,
    val url: String? = null,
    val categories: List<String> = listOf(),
    val attendanceMode: EventAttendanceMode = EventAttendanceMode.OFFLINE,
) {

    constructor(event: Event) : this(
        id = event.id,
        name = event.name,
        description = event.description,
        date = dateString(event.startDate, event.endDate) ?: "",
        venue = event.extras?.location?.let {
            Venue(
                it,
                firstLine = (event.extras?.street ?: "") + " " + (event.extras?.houseNumber ?: ""),
                secondLine = (event.extras?.postcode ?: "") + " " + (event.extras?.place ?: "")
            )
        },
        organizer = event.extras?.organizer,
        isLive = isActive(event.startDate, event.endDate),
        categories = (event.category ?: "").split(",").map { it.trim() },
        url = event.url,
        attendanceMode = event.extras?.attendanceMode ?: defaultAttendanceMode
    )

    companion object {

        fun isActive(startDate: Date?, endDate: Date?): Boolean {
            val current = Date()

            if (startDate != null && endDate != null) {
                return current >= startDate && current <= endDate
            }

            startDate?.let { start ->

                val calendar = Calendar.getInstance()
                calendar.time = start
                calendar.add(Calendar.MINUTE, eventActiveMinuteThreshold)

                return start <= current && calendar.time >= current

            }

            return false
        }

        fun dateString(startDate: Date?, endDate: Date?): String? {

            startDate?.let { start ->

                val timeComponents = timeComponent(start, endDate)

                endDate?.let { end ->
                    return "${timeComponents.day}, ${timeComponents.date} ${timeComponents.startTime}-${timeComponents.endTime}"
                }

                val calendar = Calendar.getInstance(Locale.getDefault())
                calendar.time = start

                return if (calendar.get(Calendar.HOUR_OF_DAY) == 0 && calendar.get(Calendar.MINUTE) == 0) {
                    "${timeComponents.day}, ${timeComponents.date}"
                } else {
                    "${timeComponents.day}, ${timeComponents.date} ${timeComponents.startTime}"
                }

            }

            return null
        }

        private fun timeComponent(startDate: Date, endDate: Date?): TimeComponent {

            val day = SimpleDateFormat("EEEE", Locale.getDefault())
                .format(startDate)
                .subSequence(0, 2)
                .toString()

            val date = SimpleDateFormat("dd.MM.", Locale.getDefault()).format(startDate)
            val startTime = SimpleDateFormat("HH:mm", Locale.getDefault()).format(startDate)

            endDate?.let { end ->
                val endTime = SimpleDateFormat("HH:mm", Locale.getDefault()).format(end)
                return TimeComponent(day, date, startTime, endTime)
            }

            return TimeComponent(day, date, startTime, "")
        }

    }

}