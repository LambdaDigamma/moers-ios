package com.lambdadigamma.newsfeature.di

import com.lambdadigamma.newsfeature.data.NewsService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NewsModule {

    @Provides
    @Singleton
    fun provideNewsService(): NewsService = Retrofit.Builder()
        .baseUrl("https://rp-online.de/")
        .client(OkHttpClient())
        .build()
        .create(NewsService::class.java)

}
