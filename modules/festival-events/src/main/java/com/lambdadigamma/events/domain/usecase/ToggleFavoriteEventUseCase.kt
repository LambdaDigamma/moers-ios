package com.lambdadigamma.events.domain.usecase

import com.lambdadigamma.events.domain.models.EventDetailData
import com.lambdadigamma.events.domain.repository.EventRepository
import kotlinx.coroutines.flow.Flow


fun interface ToggleFavoriteEventUseCase : suspend (Int) -> Unit

suspend fun toggleFavoriteEvent(
    eventId: Int,
    eventRepository: EventRepository,
) {

    return eventRepository.toggleFavoriteEvent(eventId)

//    return eventRepository
//        .toggleFavoriteEvent(eventId)
//        .map {
//            Result.success(it)
//        }
//        .retryWhen { cause, _ ->
//            if (cause is IOException) {
//                emit(Result.failure(cause))
//
//                delay(RETRY_TIME_IN_MILLIS)
//                true
//            } else {
//                false
//            }
//        }
//        .catch { // for other than IOException but it will stop collecting Flow
//            emit(Result.failure(it)) // also catch does re-throw CancellationException
//        }

}