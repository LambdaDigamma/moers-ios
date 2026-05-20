package com.lambdadigamma.events.domain.usecase

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.domain.repository.EventRepository
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.retryWhen
import java.io.IOException

private const val RETRY_TIME_IN_MILLIS = 15_000L

fun interface SearchEventsUseCase : (String) -> Flow<Result<List<Event>>>

fun searchEvents(
    query: String,
    eventRepository: EventRepository,
): Flow<Result<List<Event>>> {
    return eventRepository
        .searchEvents(query)
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
        .catch {
            emit(Result.failure(it))
        }
}
