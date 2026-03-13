package com.lambdadigamma.core.base

import android.content.Context
import com.google.gson.GsonBuilder
import com.lambdadigamma.core.Global
import com.lambdadigamma.core.LiveDataCallAdapterFactory
import com.lambdadigamma.core.utils.AcceptLanguageHeaderInterceptor
import com.lambdadigamma.core.utils.GsonUTCDateAdapter
import okhttp3.Cache
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.Date

object ServiceFactory {

    inline fun <reified T>getService(
        baseUrl: String,
        gsonBuilder: (GsonBuilder) -> GsonBuilder = { it },
        context: Context
    ): T {

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

        val builder = gsonBuilder(
            GsonBuilder().registerTypeAdapter(Date::class.java, GsonUTCDateAdapter())
        )

        return Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(client)
            .addConverterFactory(
                GsonConverterFactory.create(
                    builder.create()
                )
            )
            .addCallAdapterFactory(LiveDataCallAdapterFactory())
            .build()
            .create(T::class.java)
    }

}