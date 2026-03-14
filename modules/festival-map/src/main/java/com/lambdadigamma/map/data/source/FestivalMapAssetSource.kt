package com.lambdadigamma.map.data.source

import android.content.Context
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

internal interface FestivalMapAssetSource {
    fun readLayer(type: FestivalMapLayerType): String
}

internal class AndroidFestivalMapAssetSource @Inject constructor(
    @param:ApplicationContext private val context: Context,
) : FestivalMapAssetSource {

    override fun readLayer(type: FestivalMapLayerType): String {
        return context.resources
            .openRawResource(type.assetResId)
            .bufferedReader()
            .use { it.readText() }
    }
}
