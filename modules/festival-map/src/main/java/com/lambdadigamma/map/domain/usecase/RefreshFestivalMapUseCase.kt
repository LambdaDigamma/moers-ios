package com.lambdadigamma.map.domain.usecase

import com.lambdadigamma.map.data.repository.FestivalMapRepository

fun interface RefreshFestivalMapUseCase : suspend (Boolean) -> Result<Unit>

internal suspend fun refreshFestivalMap(
    repository: FestivalMapRepository,
    force: Boolean,
): Result<Unit> {
    return repository.refreshLayers(force = force)
}
