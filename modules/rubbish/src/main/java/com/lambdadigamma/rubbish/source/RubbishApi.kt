package com.lambdadigamma.rubbish.source

import com.lambdadigamma.core.DataResponse
import com.lambdadigamma.rubbish.RubbishCollectionItem
import com.lambdadigamma.rubbish.RubbishCollectionStreet
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path

interface RubbishApi {

    @GET("rubbish/streets?all")
    suspend fun streets(): DataResponse<List<RubbishCollectionStreet>>

    @GET("rubbish/streets/{id}/pickups")
    suspend fun pickups(@Path("id") streetId: Long): DataResponse<List<RubbishCollectionItem>>

    companion object {
        fun create(): RubbishApi = Retrofit.Builder()
            .baseUrl("https://moers.app/api/v1/")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(RubbishApi::class.java)
    }
}
