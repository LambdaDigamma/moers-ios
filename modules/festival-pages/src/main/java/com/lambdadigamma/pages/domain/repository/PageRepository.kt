package com.lambdadigamma.pages.domain.repository

import com.lambdadigamma.pages.data.remote.model.Page
import kotlinx.coroutines.flow.Flow

interface PageRepository {

    suspend fun refreshPage(pageId: Int)

    fun getPage(pageId: Int): Flow<Page?>

}