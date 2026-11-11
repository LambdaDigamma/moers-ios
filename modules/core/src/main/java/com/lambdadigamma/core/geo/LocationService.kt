package com.lambdadigamma.core.geo

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.*
import com.google.android.gms.tasks.CancellationTokenSource
import com.google.android.gms.tasks.Task
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeoutOrNull
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

interface LocationService {

    @Throws(LocationPermissionException::class)
    fun getCurrentLocation(): MutableSharedFlow<Location>

    /** The current or last known location, or `null` without a location permission or fix. */
    suspend fun currentLocation(): Point?

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
                val location = locationResult.lastLocation
                location?.let {
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
                val location = locationResult.lastLocation
                location?.let {
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
) : LocationService {

    private val fusedLocationProvider: FusedLocationProviderClient = LocationServices
        .getFusedLocationProviderClient(context)

    private val location: MutableSharedFlow<Location> = MutableSharedFlow()

    override fun getCurrentLocation(): MutableSharedFlow<Location> {
        if (!hasLocationPermission()) {
            throw LocationPermissionException()
        }
        return location
    }

    fun hasLocationPermission(): Boolean =
        ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED ||
            ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    @SuppressLint("MissingPermission")
    override suspend fun currentLocation(): Point? {
        if (!hasLocationPermission()) return null
        return try {
            val current = withTimeoutOrNull(CURRENT_LOCATION_TIMEOUT_MILLIS) {
                val cancellation = CancellationTokenSource()
                fusedLocationProvider
                    .getCurrentLocation(Priority.PRIORITY_BALANCED_POWER_ACCURACY, cancellation.token)
                    .awaitNullable { cancellation.cancel() }
            }
            (current ?: fusedLocationProvider.lastLocation.awaitNullable())
                ?.let { Point(latitude = it.latitude, longitude = it.longitude) }
        } catch (e: SecurityException) {
            Log.w("GMSLocationService", "Location permission was revoked", e)
            null
        } catch (e: Exception) {
            Log.w("GMSLocationService", "Location is not available", e)
            null
        }
    }

    private companion object {
        const val CURRENT_LOCATION_TIMEOUT_MILLIS = 10_000L
    }
}

/** Awaits a Play services task whose result may be `null`. */
private suspend fun <T> Task<T>.awaitNullable(onCancel: () -> Unit = {}): T? =
    suspendCancellableCoroutine { continuation ->
        addOnSuccessListener { continuation.resume(it) }
        addOnFailureListener { continuation.resumeWithException(it) }
        addOnCanceledListener { continuation.cancel() }
        continuation.invokeOnCancellation { onCancel() }
    }
