package com.lambdadigamma.events.models

import com.lambdadigamma.core.utils.AcceptLanguageHeaderInterceptor
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface EventService {

    @GET("events")
    suspend fun getEvents(
        @Query("page[size]") pageSize: Int,
        @Query("page[number]") pageNumber: Int,
    ): EventPageResponse

    @GET("events/{id}")
    suspend fun getEvent(@Path("id") id: Int): EventDto

    companion object {

        fun create(): EventService {
            val client = OkHttpClient.Builder()
                .addInterceptor(AcceptLanguageHeaderInterceptor())
                .build()

            return Retrofit.Builder()
                .baseUrl("https://moers.app/api/v1/")
                .client(client)
                .addConverterFactory(GsonConverterFactory.create())
                .build()
                .create(EventService::class.java)
        }
    }
}
