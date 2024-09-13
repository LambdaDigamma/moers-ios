package com.lambdadigamma.core

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.lambdadigamma.core.geo.GoogleMapsNavigationProvider
import com.lambdadigamma.core.geo.TravelMode
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class GoogleMapsNavigationProviderTest {

    @Test
    fun testBuildUri() {

        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val provider = GoogleMapsNavigationProvider(context)

        assertEquals(
            "https://www.google.com/maps/dir/?api=1&destination=51.448212%2C6.659806&travelmode=driving&dir_action=navigate",
            provider.buildUri(
                latitude = 51.448212,
                longitude = 6.659806,
                travelMode = TravelMode.DRIVING
            ).toString()
        )
    }

}