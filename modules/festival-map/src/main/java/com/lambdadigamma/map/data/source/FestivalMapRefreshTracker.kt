package com.lambdadigamma.map.data.source

import android.content.Context
import com.lambdadigamma.core.utils.LastUpdate
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import dagger.hilt.android.qualifiers.ApplicationContext
import java.util.Date
import java.util.concurrent.TimeUnit
import javax.inject.Inject

internal interface FestivalMapRefreshTracker {
    fun shouldRefresh(
        type: FestivalMapLayerType,
        ttlMinutes: Long,
    ): Boolean

    fun markRefreshed(type: FestivalMapLayerType)
}

internal class AndroidFestivalMapRefreshTracker @Inject constructor(
    @param:ApplicationContext private val context: Context,
) : FestivalMapRefreshTracker {

    override fun shouldRefresh(
        type: FestivalMapLayerType,
        ttlMinutes: Long,
    ): Boolean {
        val lastUpdate = trackerFor(type).get() ?: return true
        val maxAgeMillis = TimeUnit.MINUTES.toMillis(ttlMinutes)
        return Date().time - lastUpdate.time >= maxAgeMillis
    }

    override fun markRefreshed(type: FestivalMapLayerType) {
        trackerFor(type).set(Date())
    }

    private fun trackerFor(type: FestivalMapLayerType): LastUpdate {
        return LastUpdate(
            key = "festival-map-${type.remoteKey}",
            context = context,
        )
    }
}
