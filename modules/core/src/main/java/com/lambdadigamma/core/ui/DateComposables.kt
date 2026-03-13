package com.lambdadigamma.core.ui

import android.content.Context
import android.os.Build
import android.text.format.DateUtils
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextOverflow
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Date
import java.util.Formatter
import java.util.Locale
import java.util.TimeZone

fun dateToZonedDateTime(date: Date): ZonedDateTime {
    val instant = Instant.ofEpochMilli(date.time)
    return ZonedDateTime.ofInstant(instant, ZoneOffset.UTC)
        .withZoneSameInstant(ZoneId.systemDefault())
}

fun Date.toLocalDateTime(): ZonedDateTime? {
    val utcInstant = this.toInstant() // convert the Date object to an Instant in UTC

    print("Date: ")
    println(utcInstant)

    val zoneId = ZoneId.of("Europe/Berlin") // create a ZoneId for the Europe/Berlin timezone
    val dateTime = LocalDateTime.ofInstant(utcInstant, zoneId) // convert the Instant to a LocalDateTime in the Europe/Berlin timezone

    return dateTime.atZone(zoneId)
}

fun ClosedRange<Date>.formatted(context: Context, timeZone: TimeZone = TimeZone.getDefault()): String {
    val f = Formatter(StringBuilder(50), Locale.getDefault())

    val start = this.start // toLocalDateTime()
    val end = this.endInclusive //.toLocalDateTime()

    return DateUtils.formatDateRange(
        context,
        f,
        start.time,
        end.time,
        DateUtils.FORMAT_SHOW_TIME or DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_SHOW_YEAR or DateUtils.FORMAT_ABBREV_ALL,
        timeZone.id
    ).toString()
}

fun ClosedRange<Date>.formattedShort(context: Context, timeZone: TimeZone = TimeZone.getDefault()): String {
    val f = Formatter(StringBuilder(50), Locale.getDefault())

    val start = this.start // toLocalDateTime()
    val end = this.endInclusive //.toLocalDateTime()

    return DateUtils.formatDateRange(
        context,
        f,
        start.time,
        end.time,
        DateUtils.FORMAT_SHOW_TIME,
        timeZone.id
    ).toString()
}

@Composable
fun LocalTimezoneDate(
    date: Date,
    modifier: Modifier = Modifier,
    style: TextStyle = TextStyle.Default,
    onTextLayout: (TextLayoutResult) -> Unit = {},
    overflow: TextOverflow = TextOverflow.Clip,
    softWrap: Boolean = true,
    maxLines: Int = Int.MAX_VALUE,
    minLines: Int = 1
) {
    val instant = Instant.ofEpochMilli(date.time)
    val zonedDateTime = ZonedDateTime.ofInstant(instant, ZoneOffset.UTC)
        .withZoneSameInstant(ZoneId.systemDefault())
    val formatter = DateTimeFormatter.ofLocalizedDateTime(FormatStyle.LONG)

    BasicText(
        text = formatter.format(zonedDateTime),
        modifier = modifier,
        style = style,
        onTextLayout = onTextLayout,
        overflow = overflow,
        softWrap = softWrap,
        maxLines = maxLines,
        minLines = minLines
    )
}