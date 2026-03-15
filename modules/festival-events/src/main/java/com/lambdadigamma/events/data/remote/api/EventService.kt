package com.lambdadigamma.events.data.remote.api

import android.content.Context
import androidx.lifecycle.LiveData
import com.google.gson.GsonBuilder
import com.lambdadigamma.core.DataResponse
import com.lambdadigamma.core.Global
import com.lambdadigamma.core.LiveDataCallAdapterFactory
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.utils.AcceptLanguageHeaderInterceptor
import com.lambdadigamma.core.utils.GsonUTCDateAdapter
import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.data.remote.model.EventOverviewResponse
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerDeserializer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerSerializer
import com.lambdadigamma.pages.data.remote.api.registerPageBlockTypeAdapter
import okhttp3.Cache
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import java.io.File
import java.util.Date


interface EventService {

    /* Events */

    @GET("events")
    fun getEvents(): LiveData<Resource<DataResponse<List<Event>>>>

    @GET("events")
    suspend fun getAllEvents(): DataResponse<List<Event>>

    @GET("content")
    suspend fun getContent(): DataResponse<List<Event>>

    @GET("events/{id}")
    fun getEvent(@Path("id") id: Int): LiveData<Resource<Event>>

    @GET("events/overview")
    fun getEventOverview(): LiveData<Resource<DataResponse<EventOverviewResponse>>>

    /* Moers Festival */

//    @GET("moers-festival/events")
//    fun getMoersFestivalEvents(): LiveData<Resource<List<Event>>>

    companion object Factory {

        fun getMeinMoersService(context: Context): EventService {

            val client = OkHttpClient()
                .newBuilder()
                .addInterceptor(AcceptLanguageHeaderInterceptor())
                .cache(
                    Cache(
                        directory = context.getDir(Global.serviceApiCache, Context.MODE_PRIVATE),
                        maxSize = 50L * 1024L * 1024L // 50 MiB
                    )
                )
                .build()

            return Retrofit.Builder()
                .baseUrl("https://moers.app/api/v1/festival/")
//                .baseUrl("https://moers-festival.localhost/api/v1/festival/")
                .client(client)
                .addConverterFactory(
                    GsonConverterFactory.create(
                        GsonBuilder()
//                            .setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'")
                            .registerTypeAdapter(Date::class.java, GsonUTCDateAdapter())
                            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerDeserializer())
                            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerSerializer())
                            .registerPageBlockTypeAdapter()
                            .create()
                    )
                )
                .addCallAdapterFactory(LiveDataCallAdapterFactory())
                .build()
                .create(EventService::class.java)
        }

    }

}
