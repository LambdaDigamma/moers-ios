package app.moers.core.notifications

import java.util.*

fun Date.overrideHoursAndMinutes(hours: Int, minutes: Int): Date {
    val calendar = Calendar.getInstance()
    calendar.time = this
    calendar.set(Calendar.HOUR_OF_DAY, hours)
    calendar.set(Calendar.MINUTE, minutes)
    return calendar.time
}

fun Date.milliInterval(other: Date): Long {
    return other.time - this.time
}
