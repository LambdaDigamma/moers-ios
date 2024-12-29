package com.lambdadigamma.parking

import androidx.annotation.StringRes
import androidx.compose.ui.graphics.Color
import com.google.gson.annotations.SerializedName
import com.lambdadigamma.core.geo.GeoJsonPoint
import java.util.*

enum class ParkingAreaOpeningState(val value: String) {
    @SerializedName("open")
    OPEN("open"),

    @SerializedName("closed")
    CLOSED("closed"),

    @SerializedName("unknown")
    UNKNOWN("unknown")
}

fun ParkingAreaOpeningState.backgroundColor(): Color {
    return when (this) {
        ParkingAreaOpeningState.OPEN -> Color(0xFF4CAF50)
        ParkingAreaOpeningState.CLOSED -> Color(0xFFF44336)
        ParkingAreaOpeningState.UNKNOWN -> Color.Gray
    }
}

fun ParkingAreaOpeningState.textColor(): Color {
    return when (this) {
        ParkingAreaOpeningState.OPEN -> Color.White
        ParkingAreaOpeningState.CLOSED -> Color.White
        ParkingAreaOpeningState.UNKNOWN -> Color.Black
    }
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
    val location: GeoJsonPoint,
    @SerializedName("current_opening_state") val currentOpeningState: ParkingAreaOpeningState,
    @SerializedName("capacity") val capacity: Int,
    @SerializedName("occupied_sites") val occupiedSites: Int,
    @SerializedName("created_at") val createdAt: Date?,
    @SerializedName("updated_at") val updatedAt: Date?
)