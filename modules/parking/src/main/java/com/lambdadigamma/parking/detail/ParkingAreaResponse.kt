package com.lambdadigamma.parking.detail

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.parking.ParkingArea

data class ParkingAreaResponse(
    @SerializedName("parking_area") val parkingArea: ParkingArea,
    @SerializedName("past_occupancy") val pastOccupancy: PastOccupancy?,
)

/** Share of occupied sites in one hour of the last day. The API sends both values as strings. */
data class Occupancy(
    @SerializedName("occupancy_rate") val occupancyRate: Double,
    @SerializedName("hour") val hour: Int,
)

data class PastOccupancy(
    @SerializedName("max_capacity") val maxCapacity: Int?,
    @SerializedName("data") val data: OccupancyWrapper?,
)

data class OccupancyWrapper(
    @SerializedName("data") val data: List<Occupancy>?
)
