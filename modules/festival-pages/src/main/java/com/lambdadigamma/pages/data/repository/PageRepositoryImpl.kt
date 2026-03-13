package com.lambdadigamma.pages.data.repository

import com.lambdadigamma.pages.data.local.dao.PageDao
import com.lambdadigamma.pages.data.mapper.toDomainModel
import com.lambdadigamma.pages.data.mapper.toEntityModel
import com.lambdadigamma.pages.data.remote.api.PageService
import com.lambdadigamma.pages.data.remote.model.Page
import com.lambdadigamma.pages.domain.repository.PageRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onEach
import timber.log.Timber
import javax.inject.Inject

class PageRepositoryImpl @Inject constructor(
    private val pageApi: PageService,
    private val pageDao: PageDao,
) : PageRepository {

    override fun getPage(pageId: Int): Flow<Page?> {

        return pageDao.getPageWithBlocks(pageId)
            .map { pageCached ->
                if (pageCached == null) {
                    return@map null
                }
                val page = pageCached.page.toDomainModel()
                val blocks = pageCached.blocks.sortedBy { it.order }.map { it.toDomainModel() }
                return@map page.copy(blocks = blocks)
            }
            .onEach { page ->
                if (page == null) {
                    refreshPage(pageId)
                }
            }
    }

    override suspend fun refreshPage(pageId: Int) {
        pageApi
            .getPage(pageId)
            .data
            .also {
                pageDao.savePages(listOf(it.toEntityModel()))
                pageDao.savePageBlocks(it.blocks.map { block -> block.toEntityModel() })
            }
    }

}