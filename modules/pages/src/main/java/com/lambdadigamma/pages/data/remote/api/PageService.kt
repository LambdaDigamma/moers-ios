package com.lambdadigamma.pages.data.remote.api

import com.lambdadigamma.core.DataResponse
import com.lambdadigamma.pages.data.remote.model.Page
import retrofit2.http.GET
import retrofit2.http.Path

interface PageService {

    @GET("pages/{id}")
    suspend fun getPage(@Path("id") id: Int): DataResponse<Page>

}