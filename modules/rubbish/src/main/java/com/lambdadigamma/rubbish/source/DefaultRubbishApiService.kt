package com.lambdadigamma.rubbish.source

import androidx.lifecycle.LiveData
import com.lambdadigamma.core.DataResponse
import com.lambdadigamma.core.LiveDataCallAdapterFactory
import com.lambdadigamma.core.Resource
import com.lambdadigamma.rubbish.RubbishCollectionItem
import com.lambdadigamma.rubbish.RubbishCollectionStreet
import com.skydoves.retrofit.adapters.result.ResultCallAdapterFactory
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface DefaultRubbishApiService : RubbishApi {

    @GET("rubbish/streets")
    override fun fetchStreets(@Query("q") streetName: String?): LiveData<Resource<DataResponse<List<RubbishCollectionStreet>>>>

    @GET("rubbish/streets/{id}/pickups")
    override suspend fun getPickupItems(@Path("id") streetId: Long): Result<DataResponse<List<RubbishCollectionItem>>>

    companion object Factory {

        fun getRubbishService(): DefaultRubbishApiService {
            return Retrofit.Builder()
                .baseUrl("https://moers.app/api/v1/")
                .addConverterFactory(GsonConverterFactory.create())
                .addCallAdapterFactory(LiveDataCallAdapterFactory())
                .addCallAdapterFactory(ResultCallAdapterFactory.create())
                .build()
                .create(DefaultRubbishApiService::class.java)
        }

    }

}