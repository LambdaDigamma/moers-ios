package com.lambdadigamma.core

import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Test
import org.junit.runner.RunWith


@RunWith(AndroidJUnit4::class)
class DefaultLocationServiceTest {

    @Test
    fun placeholder() {

    }

//    @Rule
//    @JvmField
//    val grantPermissionRule: GrantPermissionRule =
//        GrantPermissionRule.grant(Manifest.permission.ACCESS_FINE_LOCATION)

//    @Test
//    @OptIn(ExperimentalCoroutinesApi::class)
//    fun requestLastKnownLocationNull_WhenNotAuthorized() = runTest {
//
//        val appContext = InstrumentationRegistry.getInstrumentation().targetContext
//        val locationService = GMSLocationService(appContext)
//        val lastLocation = locationService.loadLastLocation()
//
//        Assert.assertFalse(locationService.checkCoarseLocationPermission())
//        Assert.assertFalse(locationService.checkFineLocationPermission())
//        Assert.assertNull(lastLocation)
//
//    }
//
//    @After
//    fun tearDown() {
//        val automation = InstrumentationRegistry
//            .getInstrumentation()
//            .uiAutomation
//
//        automation.revokeRuntimePermission(
//            getTargetContext().packageName,
//            "android.permission.ACCESS_FINE_LOCATION"
//        )
//        automation.revokeRuntimePermission(
//            getTargetContext().packageName,
//            "android.permission.ACCESS_COARSE_LOCATION"
//        )
//    }

//    @Test
//    fun requestLastKnownLocationNotNull_WhenAuthorized() = runTest {
//
//        val targetLocation = Location("")
//        targetLocation.latitude = 0.0
//        targetLocation.longitude = 0.0
//
//        val appContext = InstrumentationRegistry.getInstrumentation().targetContext
//        val locationService = GMSLocationService(appContext, lastKnownLocation = targetLocation)
//
////        GrantPermissionRule.grant(Manifest.permission.ACCESS_FINE_LOCATION)
////        GrantPermissionRule.grant(Manifest.permission.ACCESS_COARSE_LOCATION)
//
//        val lastLocation = locationService.loadLastLocation()
//
//        val permission = ActivityCompat.checkSelfPermission(
//            appContext,
//            Manifest.permission.ACCESS_COARSE_LOCATION
//        )
//
//        Assert.assertEquals(permission, PackageManager.PERMISSION_GRANTED)
//        Assert.assertTrue(locationService.checkFineLocationPermission())
//
//        Assert.assertNotNull(lastLocation)
//
//    }

}