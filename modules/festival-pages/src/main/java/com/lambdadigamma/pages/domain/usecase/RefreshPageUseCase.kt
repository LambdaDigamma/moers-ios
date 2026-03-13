package com.lambdadigamma.pages.domain.usecase

import com.lambdadigamma.core.extensions.resultOf
import com.lambdadigamma.pages.domain.repository.PageRepository

fun interface RefreshPageUseCase : suspend (Int) -> Result<Unit>

suspend fun refreshPage(
    pageId: Int,
    pageRepository: PageRepository,
): Result<Unit> = resultOf {
    pageRepository.refreshPage(pageId)
}
