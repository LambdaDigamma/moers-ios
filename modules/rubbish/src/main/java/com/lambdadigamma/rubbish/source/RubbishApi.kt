package com.lambdadigamma.rubbish.source

import androidx.lifecycle.LiveData
import com.lambdadigamma.core.DataResponse
import com.lambdadigamma.core.Resource
import com.lambdadigamma.rubbish.RubbishCollectionItem
import com.lambdadigamma.rubbish.RubbishCollectionStreet
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface RubbishApi {

    @GET("rubbish/streets?all")
    fun fetchStreets(@Query("q") streetName: String? = null): LiveData<Resource<DataResponse<List<RubbishCollectionStreet>>>>

    @GET("rubbish/streets/{id}/pickups")
    suspend fun getPickupItems(@Path("id") streetId: Long): Result<DataResponse<List<RubbishCollectionItem>>>

}