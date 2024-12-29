package com.lambdadigamma.core

import com.lambdadigamma.core.notifications.milliInterval
import com.lambdadigamma.core.notifications.overrideHoursAndMinutes
import org.junit.Assert
import org.junit.Test
import java.util.*

class DateUtilsTest {

    @Test
    fun testOverrideHourAndMinute() {
        val date = Date().overrideHoursAndMinutes(hours = 20, minutes = 0)

        Assert.assertEquals(20, date.hours)
        Assert.assertEquals(0, date.minutes)

    }

    @Test
    fun testMilliInterval() {

        val date = Date()
        val otherDate = Date()

        otherDate.time += 1000

        Assert.assertEquals(1000, date.milliInterval(otherDate))

    }

}