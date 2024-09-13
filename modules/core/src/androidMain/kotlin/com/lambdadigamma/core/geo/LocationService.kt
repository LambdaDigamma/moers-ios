package com.lambdadigamma.core.geo

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.*
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.suspendCancellableCoroutine
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

interface LocationService {

    @Throws(LocationPermissionException::class)
    fun getCurrentLocation(): MutableSharedFlow<Location>

    suspend fun awaitLastLocation(): Location

}

class LocationUpdatesUseCase @Inject constructor(
    @ApplicationContext val context: Context
) {

    private val client: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(context)

    fun fetchUpdates(interval: Int): Flow<Point> = callbackFlow {
        val locationRequest = LocationRequest.create()
            .setInterval(TimeUnit.SECONDS.toMillis(interval.toLong()))
            .setFastestInterval(TimeUnit.SECONDS.toMillis(FASTEST_UPDATE_INTERVAL_SECS))
            .setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY)

        val callBack = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                super.onLocationResult(locationResult)
                locationResult.lastLocation?.let { location ->
                    val userLocation = Point(
                        latitude = location.latitude,
                        longitude = location.longitude
                    )
                    this@callbackFlow.trySend(userLocation).isSuccess
                }
            }
        }

        client.requestLocationUpdates(locationRequest, callBack, Looper.getMainLooper())
        awaitClose { client.removeLocationUpdates(callBack) }
    }

    fun fetchCurrentLocation(): Flow<Point> = callbackFlow {
//        val locationRequest = LocationRequest().apply {
//            interval = TimeUnit.SECONDS.toMillis(UPDATE_INTERVAL_SECS)
//            fastestInterval = TimeUnit.SECONDS.toMillis(FASTEST_UPDATE_INTERVAL_SECS)
//            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
//        }

        val locationRequest = LocationRequest.create()
            .setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY)
            .setFastestInterval(TimeUnit.SECONDS.toMillis(FASTEST_UPDATE_INTERVAL_SECS))
            .setNumUpdates(1)
            .setInterval(TimeUnit.SECONDS.toMillis(1))
            .setExpirationDuration(5000)

        val callBack = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                super.onLocationResult(locationResult)
                locationResult.lastLocation?.let { location ->
                    val userLocation = Point(
                        latitude = location.latitude,
                        longitude = location.longitude
                    )
                    this@callbackFlow.trySend(userLocation).isSuccess
                }
            }
        }

        client.requestLocationUpdates(locationRequest, callBack, Looper.getMainLooper())
        awaitClose { client.removeLocationUpdates(callBack) }
    }

    companion object {
        private const val UPDATE_INTERVAL_SECS = 10L
        private const val FASTEST_UPDATE_INTERVAL_SECS = 2L
    }
}

class LocationPermissionException : Exception()

class GMSLocationService(
    val context: Context,
    lastKnownLocation: Location? = null
) : LocationService {

    private var fusedLocationProvider: FusedLocationProviderClient = LocationServices
        .getFusedLocationProviderClient(context)

    init {
        lastKnownLocation?.let {
            if (!checkFineLocationPermission() && !checkCoarseLocationPermission()) {
                return@let
            }
            fusedLocationProvider.setMockLocation(it)
            fusedLocationProvider.setMockMode(true)
        }
    }

    private var location: MutableSharedFlow<Location> = MutableSharedFlow()

    override fun getCurrentLocation(): MutableSharedFlow<Location> {

        if (!checkFineLocationPermission() && !checkCoarseLocationPermission()) {
            throw LocationPermissionException()
        }

//        fusedLocationProvider.getCurrentLocation()

//        fusedLocationProvider.getCurrentLocation()
//            .addOnSuccessListener { location ->
//                this.location.tryEmit(location)
//            }

        return location

    }

    fun checkFineLocationPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    fun checkCoarseLocationPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    suspend fun loadLastLocation(): Point? {

        return suspendCoroutine { continuation ->

            if (!checkCoarseLocationPermission()) {
                Log.i("GMSLocationService", "No coarse location permission")
                continuation.resume(null)
            }

            val locationRequest = LocationRequest.create()
                .setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY)
                .setNumUpdates(1)
                .setInterval(1)
                .setExpirationDuration(1000)

            val listener = object : LocationCallback() {
                override fun onLocationResult(p0: LocationResult) {
                    p0.lastLocation?.let { location ->
                        continuation.resume(
                            Point(
                                latitude = location.latitude,
                                longitude = location.longitude
                            )
                        )
                    }
                }
            }

            val task = fusedLocationProvider.requestLocationUpdates(
                locationRequest,
                listener,
                Looper.getMainLooper()
            )

            task.addOnFailureListener { continuation.resumeWithException(it) }

        }

    }

    override suspend fun awaitLastLocation(): Location {
        return fusedLocationProvider.awaitLastLocation()
    }
}

suspend fun FusedLocationProviderClient.awaitLastLocation(): Location =
    suspendCancellableCoroutine<Location> { continuation ->
        // Add listeners that will resume the execution of this coroutine
        lastLocation.addOnSuccessListener { location ->
            // Resume coroutine and return location
            continuation.resume(location)
        }.addOnFailureListener { e ->
            // Resume the coroutine by throwing an exception
            continuation.resumeWithException(e)
        }
    }