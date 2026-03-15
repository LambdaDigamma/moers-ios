package com.lambdadigamma.news.domain.usecase

import com.lambdadigamma.events.domain.models.EventDetailData
import com.lambdadigamma.events.domain.repository.EventRepository
import com.lambdadigamma.news.data.remote.model.Post
import com.lambdadigamma.news.domain.models.PostDetailData
import com.lambdadigamma.news.domain.repository.PostRepository
import com.lambdadigamma.news.presentation.PostDisplayable
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.retryWhen
import java.io.IOException

private const val RETRY_TIME_IN_MILLIS = 15_000L

fun interface GetPostDetailUseCase : (Int) -> Flow<Result<PostDetailData?>>

fun getPostDetail(
    postId: Int,
    repository: PostRepository,
): Flow<Result<PostDetailData?>> {

    return repository
        .getPost(postId)
        .map {
            Result.success(it)
        }
        .retryWhen { cause, _ ->
            if (cause is IOException) {
                emit(Result.failure(cause))

                delay(RETRY_TIME_IN_MILLIS)
                true
            } else {
                false
            }
        }
        .catch { // for other than IOException but it will stop collecting Flow
            emit(Result.failure(it)) // also catch does re-throw CancellationException
        }

}