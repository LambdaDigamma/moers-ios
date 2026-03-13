package com.lambdadigamma.pages.data

import com.lambdadigamma.pages.data.local.dao.PageDao
import com.lambdadigamma.pages.data.remote.api.PageService
import com.lambdadigamma.pages.data.repository.PageRepositoryImpl
import com.lambdadigamma.pages.domain.repository.PageRepository
import io.mockk.MockKAnnotations
import io.mockk.every
import io.mockk.impl.annotations.RelaxedMockK
import kotlinx.coroutines.flow.flowOf
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

class PageRepositoryTest {

    @RelaxedMockK
    private lateinit var pageService: PageService

    @RelaxedMockK
    private lateinit var pageDao: PageDao

    private lateinit var objectUnderTest: PageRepository

    @BeforeEach
    fun setUp() {
        MockKAnnotations.init(this)
        setUpPageRepository()
    }

    @Test
    fun `should refresh page if it is not in local database`() {
        // Given
//        every { pageDao.getPageWithBlocks(1) } returns flowOf(null)

    }

    private fun setUpPageRepository() {
        objectUnderTest = PageRepositoryImpl(
            pageService,
            pageDao,
        )
    }

}