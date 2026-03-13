package com.lambdadigamma.map.data.remote.api

import okhttp3.ResponseBody
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path

interface FGDService {

    @GET("fgd/{key}.geojson")
    suspend fun getFGD(@Path("key") key: String): ResponseBody

    companion object {
        val fgdService: FGDService by lazy {
            RetrofitClient.retrofit.create(FGDService::class.java)
        }
    }

}