package com.lambdadigamma.parking

import androidx.annotation.StringRes
import com.google.gson.annotations.SerializedName
import com.lambdadigamma.core.geo.GeoJsonPoint
import java.util.Date

enum class ParkingAreaOpeningState(val value: String) {
    @SerializedName("open")
    OPEN("open"),

    @SerializedName("closed")
    CLOSED("closed"),

    @SerializedName("unknown")
    UNKNOWN("unknown")
}

@StringRes
fun ParkingAreaOpeningState.localizedName(): Int {
    return when (this) {
        ParkingAreaOpeningState.OPEN -> R.string.parking_area_open
        ParkingAreaOpeningState.CLOSED -> R.string.parking_area_closed
        ParkingAreaOpeningState.UNKNOWN -> R.string.parking_area_unknown
    }
}

data class ParkingArea(
    val id: Int,
    val name: String,
    val slug: String,
    val location: GeoJsonPoint?,
    @SerializedName("current_opening_state") val currentOpeningState: ParkingAreaOpeningState?,
    @SerializedName("capacity") val capacity: Int,
    @SerializedName("occupied_sites") val occupiedSites: Int,
    @SerializedName("created_at") val createdAt: Date?,
    @SerializedName("updated_at") val updatedAt: Date?
) {

    /** False when the parking guidance system reports no capacity for this area. */
    val hasLiveData: Boolean get() = capacity > 0

    val freeSites: Int get() = (capacity - occupiedSites).coerceAtLeast(0)

    /** Share of occupied sites between 0 and 1. */
    val occupancy: Float
        get() = if (capacity > 0) (occupiedSites.toFloat() / capacity).coerceIn(0f, 1f) else 0f

    val openingState: ParkingAreaOpeningState get() = currentOpeningState ?: ParkingAreaOpeningState.UNKNOWN

}

/** Parking data is considered outdated when even the newest update is older than a day. */
fun List<ParkingArea>.isOutdated(now: Date = Date()): Boolean {
    val newest = mapNotNull { it.updatedAt }.maxOrNull() ?: return isNotEmpty()
    return now.time - newest.time > 24 * 60 * 60 * 1000L
}

fun List<ParkingArea>.lastUpdate(): Date? = mapNotNull { it.updatedAt }.maxOrNull()
