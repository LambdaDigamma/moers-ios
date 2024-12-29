package com.lambdadigamma.events.models

import androidx.lifecycle.LiveData
import com.google.gson.GsonBuilder
import com.lambdadigamma.core.DataResponse
import com.lambdadigamma.core.LiveDataCallAdapterFactory
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.utils.AcceptLanguageHeaderInterceptor
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path


interface MeinMoersService {

    /* Entries */

//    @GET("entries")
//    fun getEntries(): LiveData<Resource<List<Entry>>>

    /* Events */

    @GET("events")
    fun getEvents(): LiveData<Resource<DataResponse<List<Event>>>>

    @GET("events/{id}")
    fun getEvent(@Path("id") id: Int): LiveData<Resource<Event>>

    @GET("events/overview")
    fun getEventOverview(): LiveData<Resource<DataResponse<EventOverviewResponse>>>

    /* Moers Festival */

//    @GET("moers-festival/events")
//    fun getMoersFestivalEvents(): LiveData<Resource<List<Event>>>

    companion object Factory {

        fun getMeinMoersService(): MeinMoersService {

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
                .create(MeinMoersService::class.java)
        }

    }

}