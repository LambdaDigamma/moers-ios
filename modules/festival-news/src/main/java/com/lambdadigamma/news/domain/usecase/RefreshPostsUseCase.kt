package com.lambdadigamma.news.domain.usecase

import com.lambdadigamma.core.extensions.resultOf
import com.lambdadigamma.news.domain.repository.PostRepository

fun interface RefreshPostsUseCase : suspend () -> Result<Unit>

suspend fun refreshPosts(
    postRepository: PostRepository,
): Result<Unit> = resultOf {
    postRepository.refreshPosts()
}
