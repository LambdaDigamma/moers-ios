package com.lambdadigamma.pages.domain.usecase

import com.lambdadigamma.pages.data.remote.model.Page
import com.lambdadigamma.pages.domain.repository.PageRepository
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.retryWhen
import java.io.IOException

private const val RETRY_TIME_IN_MILLIS = 15_000L

fun interface GetPageUseCase : (Int) -> Flow<Result<Page?>>

fun getPage(
    pageId: Int,
    pageRepository: PageRepository,
): Flow<Result<Page?>> {

    return pageRepository
        .getPage(pageId)
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