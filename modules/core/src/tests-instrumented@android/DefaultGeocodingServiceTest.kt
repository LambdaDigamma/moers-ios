package com.lambdadigamma.core

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.lambdadigamma.core.geo.DefaultGeocodingService
import com.lambdadigamma.core.geo.Point
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class DefaultGeocodingServiceTest {

    @Test
    @OptIn(ExperimentalCoroutinesApi::class)
    fun testReverseGeocoding() = runTest {
        val appContext = InstrumentationRegistry.getInstrumentation().targetContext
        val geocodingService = DefaultGeocodingService(appContext)
        val results = geocodingService.reverseGeocode(Point(51.448212, 6.659806))
        val geocodedAddress = results.first()

        Assert.assertNotEquals(0, results.count())
        Assert.assertEquals("Greta-Rothe-Straße", geocodedAddress.street)
        Assert.assertEquals("52", geocodedAddress.houseNumber)
        Assert.assertEquals("Moers", geocodedAddress.place)
        Assert.assertEquals("47443", geocodedAddress.postalCode)
        Assert.assertEquals("DE", geocodedAddress.countryCode)
    }

    @Test
    fun testGeocoding() {
        val appContext = InstrumentationRegistry.getInstrumentation().targetContext
        val geocodingService = DefaultGeocodingService(appContext)
        val point = geocodingService
            .geocodeBestPosition("Lindenstraße 24, 47443 Moers, Deutschland")
            ?: return Assert.fail()

        Assert.assertNotNull(point)
        Assert.assertEquals(51.4575141, point.latitude, 0.001)
        Assert.assertEquals(6.6456608, point.longitude, 0.001)
    }
}