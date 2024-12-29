package com.lambdadigamma.core

import com.lambdadigamma.core.geo.TravelMode
import org.junit.Assert.assertEquals
import org.junit.Test

class TravelModeUnitTest {

    @Test
    fun testTravelModeHasFourCases() {
        assertEquals(4, TravelMode.values().size)
    }

    @Test
    fun testConvertsToGoogleMapsCorrectly() {
        assertEquals("driving", TravelMode.DRIVING.toGoogleMapsMode())
        assertEquals("walking", TravelMode.WALKING.toGoogleMapsMode())
        assertEquals("bicycling", TravelMode.BICYCLING.toGoogleMapsMode())
        assertEquals("transit", TravelMode.TRANSIT.toGoogleMapsMode())
    }

}