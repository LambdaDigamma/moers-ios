package com.lambdadigamma.newsfeature.data

import okhttp3.ResponseBody
import retrofit2.http.GET
import retrofit2.http.Streaming
import retrofit2.http.Url

interface NewsService {

    @Streaming
    @GET
    suspend fun feed(@Url url: String): ResponseBody

}
