package app.moers.core

import com.google.gson.GsonBuilder
import app.moers.core.utils.AcceptLanguageHeaderInterceptor
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

interface ApplicationServerService {


    companion object Factory {

        fun getMeinMoersService(): ApplicationServerService {

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
                .create(ApplicationServerService::class.java)
        }

    }

}