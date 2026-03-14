package com.lambdadigamma.map.data.source

import com.lambdadigamma.map.data.model.FestivalMapLayerType
import com.lambdadigamma.map.data.remote.api.FGDService
import javax.inject.Inject

internal interface FestivalMapRemoteSource {
    suspend fun fetchLayer(type: FestivalMapLayerType): Result<String>
}

internal class DefaultFestivalMapRemoteSource @Inject constructor(
    private val service: FGDService,
) : FestivalMapRemoteSource {

    override suspend fun fetchLayer(type: FestivalMapLayerType): Result<String> {
        return runCatching {
            service.getFGD(type.remoteKey).string()
        }
    }
}
