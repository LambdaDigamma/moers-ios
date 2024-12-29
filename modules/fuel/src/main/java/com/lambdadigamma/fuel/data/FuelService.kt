package com.lambdadigamma.fuel.data

import android.util.Log
import com.google.gson.GsonBuilder
import com.lambdadigamma.core.LiveDataCallAdapterFactory
import com.skydoves.retrofit.adapters.result.ResultCallAdapterFactory
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Query

interface FuelService {

    @GET("json/list.php")
    suspend fun getFuelStations(
        @Query("lat") latitude: Double,
        @Query("lng") longitude: Double,
        @Query("rad") radius: Double,
        @Query("sort") sorting: String,
        @Query("type") type: String
    ): Result<FuelRequestResponse>

    @GET("json/detail.php")
    suspend fun getFuelStation(
        @Query("id") id: String
    ): Result<FuelStationDetailRequestResponse>

    companion object Factory {

        private const val BASE_URL = "https://creativecommons.tankerkoenig.de/"

        fun getFuelService(apiKey: String): FuelService {
            val client = OkHttpClient.Builder()
                .addInterceptor { chain ->
                    return@addInterceptor addApiKeyToRequests(
                        chain,
                        apiKey
                    )
                }
                .build()

            return Retrofit.Builder()
                .baseUrl(BASE_URL)
                .client(client)
                .addConverterFactory(
                    GsonConverterFactory.create(
                        GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create()
                    )
                )
                .addCallAdapterFactory(ResultCallAdapterFactory.create())
                .addCallAdapterFactory(LiveDataCallAdapterFactory())
                .build()
                .create(FuelService::class.java)
        }

        private fun addApiKeyToRequests(chain: Interceptor.Chain, key: String): Response {
            val request = chain.request().newBuilder()
            val originalHttpUrl = chain.request().url
            val newUrl = originalHttpUrl.newBuilder()
                .addQueryParameter("apikey", key)
                .build()
            request.url(newUrl)
            Log.d("Api", newUrl.toString())
            return chain.proceed(request.build())
        }

    }

}