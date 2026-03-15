package com.lambdadigamma.map.data.source

import android.content.Context
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import dagger.hilt.android.qualifiers.ApplicationContext
import java.io.File
import javax.inject.Inject

internal interface FestivalMapCacheSource {
    fun readLayer(type: FestivalMapLayerType): String?

    fun writeLayer(
        type: FestivalMapLayerType,
        rawJson: String,
    )
}

internal class AndroidFestivalMapCacheSource @Inject constructor(
    @param:ApplicationContext private val context: Context,
) : FestivalMapCacheSource {

    override fun readLayer(type: FestivalMapLayerType): String? {
        return fileFor(type)
            .takeIf { it.exists() }
            ?.readText()
    }

    override fun writeLayer(
        type: FestivalMapLayerType,
        rawJson: String,
    ) {
        val directory = cacheDirectory()
        if (!directory.exists()) {
            directory.mkdirs()
        }

        fileFor(type).writeText(rawJson)
    }

    private fun cacheDirectory(): File = File(context.filesDir, CACHE_DIRECTORY)

    private fun fileFor(type: FestivalMapLayerType): File {
        return File(cacheDirectory(), "${type.remoteKey}.geojson")
    }

    private companion object {
        const val CACHE_DIRECTORY = "currentFGD"
    }
}
