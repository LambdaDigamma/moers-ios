package com.lambdadigamma.parking.detail

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.parking.ParkingArea

data class ParkingAreaResponse(
    @SerializedName("parking_area") val parkingArea: ParkingArea,
    @SerializedName("past_occupancy") val pastOccupancy: PastOccupancy,
)

data class Occupancy(
    @SerializedName("occupancy_rate") val occupancyRate: Double,
    @SerializedName("hour") val hour: Int,
)

data class PastOccupancy(
    @SerializedName("max_capacity") val maxCapacity: Int,
//    val data: DataResponse<OccupancyWrapper> = DataResponse(OccupancyWrapper(listOf())),
//    @SerializedName("data") val data: DataResponse<OccupancyWrapper>
)

data class OccupancyWrapper(
    @SerializedName("data") val data: List<Occupancy>
)