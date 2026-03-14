package com.lambdadigamma.map.data.remote.api

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitClient {

    private const val BASE_URL = "https://moers.app/"

    val retrofit: Retrofit by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
//            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

}
