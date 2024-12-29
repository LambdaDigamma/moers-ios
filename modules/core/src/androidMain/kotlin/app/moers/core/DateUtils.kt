package app.moers.core

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.util.TypedValue
import androidx.annotation.AttrRes
import androidx.annotation.RequiresApi
import java.text.DateFormatSymbols
import java.text.SimpleDateFormat
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.math.abs


object DateUtils {

    @RequiresApi(Build.VERSION_CODES.O)
    fun convertToLocalDate(date: Date): LocalDate {
        return Instant.ofEpochMilli(date.time)
            .atZone(ZoneId.systemDefault())
            .toLocalDate()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun convertToLocalDate(date: Date, zoneId: ZoneId?): LocalDate {
        return Instant.ofEpochMilli(date.time)
            .atZone(zoneId)
            .toLocalDate()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun convertToDate(date: LocalDate): Date {
        return Date.from(
            date
                .atStartOfDay().atZone(
                    ZoneId.systemDefault()
                )
                .toInstant()
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun convertToDate(date: LocalDate, zoneId: ZoneId?): Date {
        return Date.from(
            date
                .atStartOfDay().atZone(
                    zoneId
                )
                .toInstant()
        )
    }

    fun format(date: Date, formatStyle: FormatStyle): String {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val dateFormatter: DateTimeFormatter =
                DateTimeFormatter.ofLocalizedDate(formatStyle)
            val localDate = this.convertToLocalDate(date)
            return localDate.format(dateFormatter)
        } else {
            return ""
        }

    }

}

fun SharedPreferences.Editor.putIntArray(key: String, value: IntArray): SharedPreferences.Editor {
    return putString(
        key, value.joinToString(
            separator = ",",
            transform = { it.toString() })
    )
}

fun SharedPreferences.getIntArray(key: String): IntArray {
    with(getString(key, "")) {
        with(if (this?.isNotEmpty() == true) split(',') else return intArrayOf()) {
            return IntArray(count()) { this[it].toInt() }
        }
    }
}

fun addingMinutes(minutes: Int): Date {
    val calendar = Calendar.getInstance()
    calendar.time = Date()
    calendar.add(Calendar.MINUTE, minutes)
    return calendar.time
}

fun Date.isInBeforeInterval(minutes: Double): Boolean {

    val now = Date()
    val diffInMillis = now.time - this.time
    var diff = TimeUnit.MINUTES.convert(diffInMillis, TimeUnit.MILLISECONDS)

    if (diff == 0L) {
        diff = 1L
    }

    return diffInMillis < 0 && diff >= -minutes

}

fun Date.minuteInterval(): Int {

    val now = Date()
    val diffInMillis = abs(this.time - now.time)
    var diff = TimeUnit.MINUTES.convert(diffInMillis, TimeUnit.MILLISECONDS)

    if (diff == 0L) {
        diff = 1L
    }

    return diff.toInt()

}

fun futureDate(): Date {
    val c = Calendar.getInstance()
    c.time = Date()
    c.add(Calendar.DATE, 365)
    return c.time
}

fun Context.getColorFromAttr(
    @AttrRes attrColor: Int,
    typedValue: TypedValue = TypedValue(),
    resolveRefs: Boolean = true
): Int {
    theme.resolveAttribute(attrColor, typedValue, resolveRefs)
    return typedValue.data
}

fun parseDate(date: String, format: String): Date {

    val dateFormat = SimpleDateFormat(format, Locale.getDefault())
    return dateFormat.parse(date)

}

fun format(date: Date, format: String): String {

    val sdf = SimpleDateFormat(format, Locale.getDefault())

    return sdf.format(date)

}

fun beautify(date: Date, format: String = "E dd.MM.yyyy"): String {

    var beautifiedDate = format(date, format)

    // TODO: Add Localization

    if (isToday(date)) {
        beautifiedDate = "Today, $beautifiedDate"
    } else if (isTomorrow(date)) {
        beautifiedDate = "Tomorrow, $beautifiedDate"
    }

    return beautifiedDate
}

fun isToday(date: Date): Boolean {

    val calendar = Calendar.getInstance()
    calendar.time = date
    val dateDay = calendar.get(Calendar.DAY_OF_MONTH)
    val dateMonth = calendar.get(Calendar.MONTH)
    val dateYear = calendar.get(Calendar.YEAR)

    calendar.time = Date()
    val nowDay = calendar.get(Calendar.DAY_OF_MONTH)
    val nowMonth = calendar.get(Calendar.MONTH)
    val nowYear = calendar.get(Calendar.YEAR)

    return dateDay == nowDay && dateMonth == nowMonth && dateYear == nowYear

}

fun isTomorrow(date: Date): Boolean {

    val c1 = Calendar.getInstance()
    c1.add(Calendar.DAY_OF_YEAR, 1)

    val c2 = Calendar.getInstance()
    c2.time = date

    return c1.get(Calendar.YEAR) == c2.get(Calendar.YEAR) && c1.get(Calendar.DAY_OF_YEAR) == c2.get(
        Calendar.DAY_OF_YEAR
    )

}

fun componentFor(date: Date, component: Int): Int {
    val calendar = Calendar.getInstance()
    calendar.time = date
    return calendar.get(component)
}

fun getMonthName(month: Int, locale: Locale): String {
    val symbols = DateFormatSymbols(locale)
    val monthNames = symbols.months
    return monthNames[month]
}