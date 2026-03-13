package com.lambdadigamma.news.domain.usecase

import com.lambdadigamma.core.extensions.resultOf
import com.lambdadigamma.news.data.remote.model.PostId
import com.lambdadigamma.news.domain.repository.PostRepository
import com.lambdadigamma.pages.domain.repository.PageRepository

fun interface RefreshPostUseCase : suspend (Int) -> Result<Unit>

suspend fun refreshPost(
    postId: PostId,
    postRepository: PostRepository,
): Result<Unit> = resultOf {
    postRepository.refreshPost(postId)
}
