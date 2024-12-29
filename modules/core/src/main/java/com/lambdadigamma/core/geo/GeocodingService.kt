package com.lambdadigamma.core.geo

import android.content.Context
import android.location.Geocoder
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException
import javax.inject.Inject

interface GeocodingService {

    suspend fun reverseGeocode(point: Point): List<GeocodedAddress>

    fun geocodeBestPosition(search: String): Point?

}

class DefaultGeocodingService @Inject constructor(
    @ApplicationContext val context: Context
) : GeocodingService {

    private var geocoder: Geocoder = Geocoder(context)

    override suspend fun reverseGeocode(point: Point): List<GeocodedAddress> =
        withContext(Dispatchers.IO) {
            try {
                return@withContext geocoder
                    .getFromLocation(point.latitude, point.longitude, 1)
                    .map {
                        it.toGeocodedAddress()
                    }
            } catch (e: IOException) {
                return@withContext emptyList()
            }
        }

    override fun geocodeBestPosition(search: String): Point? {
        return this
            .geocodeIntoPointList(search, maxResults = 1)
            .firstOrNull()
    }

    private fun geocodeIntoPointList(text: String, maxResults: Int = 1): List<Point> {
        return geocoder.getFromLocationName(text, maxResults)
            .filterNotNull()
            .map {
                Point(it.latitude, it.longitude)
            }
    }

}