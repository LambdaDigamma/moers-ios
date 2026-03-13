package com.lambdadigamma.events.domain.usecase

import com.lambdadigamma.events.domain.repository.EventRepository
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsData
import com.lambdadigamma.events.presentation.timetable.TimetableData
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.retryWhen
import java.io.IOException

private const val RETRY_TIME_IN_MILLIS = 15_000L

fun interface GetFavoriteEventsUseCase : () -> Flow<Result<FavoriteEventsData>>

fun getFavoriteEvents(
    eventRepository: EventRepository,
): Flow<Result<FavoriteEventsData>> {

    return eventRepository
        .getFavoriteEvents()
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