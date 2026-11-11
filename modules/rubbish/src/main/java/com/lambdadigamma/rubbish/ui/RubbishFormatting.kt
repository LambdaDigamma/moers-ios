package com.lambdadigamma.rubbish.ui

import android.text.format.DateFormat
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.stringResource
import androidx.core.os.ConfigurationCompat
import com.lambdadigamma.rubbish.R
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

/** "Today", "Tomorrow" or the weekday and date, for example "Thursday, November 12" or, [short], "Thu, Nov 12". */
@Composable
fun pickupDayLabel(date: LocalDate, short: Boolean = false): String {
    val today = LocalDate.now()
    return when (date) {
        today -> stringResource(R.string.rubbish_today)
        today.plusDays(1) -> stringResource(R.string.rubbish_tomorrow)
        else -> date.format(rememberDayFormatter(if (short) "EEEMMMd" else "EEEEMMMMd"))
    }
}

@Composable
private fun rememberDayFormatter(skeleton: String): DateTimeFormatter {
    val locale = ConfigurationCompat.getLocales(LocalConfiguration.current)[0] ?: Locale.getDefault()
    return remember(locale, skeleton) {
        DateTimeFormatter.ofPattern(DateFormat.getBestDateTimePattern(locale, skeleton), locale)
    }
}
