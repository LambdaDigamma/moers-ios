package com.lambdadigamma.newsfeature.data

import androidx.lifecycle.LiveData
import com.lambdadigamma.core.LiveDataCallAdapterFactory
import com.lambdadigamma.core.Resource
import retrofit2.Retrofit
import retrofit2.http.GET

interface NewsService {

    @GET("/nrw/staedte/moers/feed.rss")
    fun getRPFeed(): LiveData<Resource<List<RssItem>>>

    @GET("/?config=rss_moers_app")
    fun getNRZFeed(): LiveData<Resource<List<RssItem>>>

    companion object Factory {

        fun getRPService(): NewsService {
            return Retrofit.Builder()
                .baseUrl("https://rp-online.de")
                .addConverterFactory(RssConverterFactory.create())
                .addCallAdapterFactory(LiveDataCallAdapterFactory())
                .build()
                .create(NewsService::class.java)
        }

        fun getNRZService(): NewsService {
            return Retrofit.Builder()
                .baseUrl("https://www.nrz.de")
                .addConverterFactory(RssConverterFactory.create())
                .addCallAdapterFactory(LiveDataCallAdapterFactory())
                .build()
                .create(NewsService::class.java)
        }

    }

}