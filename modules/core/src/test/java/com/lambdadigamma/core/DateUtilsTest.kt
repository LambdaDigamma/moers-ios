package com.lambdadigamma.core

import com.lambdadigamma.core.notifications.milliInterval
import com.lambdadigamma.core.notifications.overrideHoursAndMinutes
import org.junit.jupiter.api.Test
import java.util.*
import kotlin.test.assertEquals

class DateUtilsTest {

    @Test
    fun testOverrideHourAndMinute() {
        val date = Date().overrideHoursAndMinutes(hours = 20, minutes = 0)
        val calendar = Calendar.getInstance().apply { time = date }

        assertEquals(20, calendar.get(Calendar.HOUR_OF_DAY))
        assertEquals(0, calendar.get(Calendar.MINUTE))

    }

    @Test
    fun testMilliInterval() {

        val date = Date()
        val otherDate = Date()

        otherDate.time += 1000

        assertEquals(1000, date.milliInterval(otherDate))

    }

}
