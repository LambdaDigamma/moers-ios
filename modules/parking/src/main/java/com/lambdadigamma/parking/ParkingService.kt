package com.lambdadigamma.parking

import androidx.lifecycle.LiveData
import com.google.gson.GsonBuilder
import com.google.gson.annotations.SerializedName
import com.lambdadigamma.core.DataResponse
import com.lambdadigamma.core.LiveDataCallAdapterFactory
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.utils.AcceptLanguageHeaderInterceptor
import com.lambdadigamma.parking.detail.ParkingAreaResponse
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path

data class ParkingAreasResponse(@SerializedName("parking_areas") val parkingAreas: List<ParkingArea>)

interface ParkingService {

    @GET("parking/dashboard")
    fun getParkingDashboard(): LiveData<Resource<DataResponse<ParkingAreasResponse>>>

    @GET("parking-areas")
    fun getParkingAreas(): LiveData<Resource<DataResponse<ParkingAreasResponse>>>

    @GET("parking-areas/{id}")
    fun getParkingArea(@Path("id") id: Int): LiveData<Resource<DataResponse<ParkingAreaResponse>>>

    companion object Factory {

        fun getParkingService(): ParkingService {

            val client = OkHttpClient()
                .newBuilder()
                .addInterceptor(AcceptLanguageHeaderInterceptor())
                .build()

            return Retrofit.Builder()
                .baseUrl("https://moers.app/api/v1/")
                .client(client)
                .addConverterFactory(
                    GsonConverterFactory.create(
                        GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create()
                    )
                )
                .addCallAdapterFactory(LiveDataCallAdapterFactory())
                .build()
                .create(ParkingService::class.java)
        }

    }
}