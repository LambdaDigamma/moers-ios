package com.lambdadigamma.core.geo

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.ContextCompat

class GoogleMapsNavigationProvider(
    val context: Context
) : NavigationProvider {

    override fun startNavigation(
        latitude: Double,
        longitude: Double,
        travelMode: TravelMode
    ) {
        val uri = buildUri(latitude = latitude, longitude = longitude, travelMode = travelMode)
        val mapIntent = Intent(Intent.ACTION_VIEW, uri)
        mapIntent.setPackage("com.google.android.apps.maps")
        mapIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return ContextCompat.startActivity(context, mapIntent, null)
    }

    override fun startNavigation(destination: Point, travelMode: TravelMode) {
        this.startNavigation(destination.latitude, destination.longitude, travelMode)
    }

    fun startNavigation(
        name: String,
        firstLine: String,
        secondLine: String?,
        travelMode: TravelMode
    ) {
        val uri = buildDirectionsUri(
            name = name,
            firstLine = firstLine,
            secondLine = secondLine,
            travelMode = travelMode
        )
        val mapIntent = Intent(Intent.ACTION_VIEW, uri)
        mapIntent.setPackage("com.google.android.apps.maps")
        mapIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return ContextCompat.startActivity(context, mapIntent, null)
    }

    fun buildDirectionsUri(
        name: String,
        firstLine: String,
        secondLine: String?,
        travelMode: TravelMode
    ): Uri {
        return Uri.parse("https://www.google.com/maps/dir/")
            .buildUpon()
            .appendQueryParameter("api", "1")
            .appendQueryParameter(
                "destination",
                listOf(name, firstLine, secondLine).joinToString(separator = ",")
            )
            .appendQueryParameter("travelmode", travelMode.toGoogleMapsMode())
            .appendQueryParameter("dir_action", "navigate")
            .build()
    }

    fun buildUri(latitude: Double, longitude: Double, travelMode: TravelMode): Uri {
        return Uri.parse("https://www.google.com/maps/dir/")
            .buildUpon()
            .appendQueryParameter("api", "1")
            .appendQueryParameter("destination", "$latitude,$longitude")
            .appendQueryParameter("travelmode", travelMode.toGoogleMapsMode())
            .appendQueryParameter("dir_action", "navigate")
            .build()
    }

}