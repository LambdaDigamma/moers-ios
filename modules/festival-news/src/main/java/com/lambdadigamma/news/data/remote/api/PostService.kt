package com.lambdadigamma.news.data.remote.api

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
import com.lambdadigamma.news.data.remote.model.FeedId
import com.lambdadigamma.news.data.remote.model.Post
import com.lambdadigamma.pages.data.remote.api.registerPageBlockTypeAdapter
import okhttp3.Cache
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query
import java.io.File
import java.util.Date


interface PostService {

    @GET("feeds/{id}/posts")
    suspend fun getPosts(
        @Path("id") feedId: FeedId,
        @Query("page[size]") size: Int,
        @Query("page[number]") page: Int,
    ): DataResponse<List<Post>>

    @GET("posts/{id}")
    suspend fun getPost(@Path("id") id: Int): DataResponse<Post>

    companion object Factory {

        fun getMeinMoersService(context: Context): PostService {

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
                .baseUrl("https://app.moers-festival.de/api/v1/")
                .client(client)
                .addConverterFactory(
                    GsonConverterFactory.create(
                        GsonBuilder()
                            .registerTypeAdapter(Date::class.java, GsonUTCDateAdapter())
                            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerDeserializer())
                            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerSerializer())
                            .registerPageBlockTypeAdapter()
                            .create()
                    )
                )
                .addCallAdapterFactory(LiveDataCallAdapterFactory())
                .build()
                .create(PostService::class.java)
        }

    }

}