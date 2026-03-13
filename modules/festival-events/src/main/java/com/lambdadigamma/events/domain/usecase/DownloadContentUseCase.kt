package com.lambdadigamma.events.domain.usecase

import com.lambdadigamma.core.extensions.resultOf
import com.lambdadigamma.events.domain.repository.EventRepository

fun interface DownloadContentUseCase : suspend () -> Result<Unit>

suspend fun downloadContent(
    eventRepository: EventRepository,
): Result<Unit> = resultOf {
    eventRepository.loadContent()
}
