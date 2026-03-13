package com.lambdadigamma.map.data.local

import android.content.Context
import com.google.maps.android.data.geojson.GeoJsonGeometryCollection
import com.google.maps.android.data.geojson.GeoJsonParser
import com.lambdadigamma.map.data.model.GeoDataLayerLocal
import dagger.hilt.android.qualifiers.ApplicationContext
import okio.FileSystem
import okio.Path
import okio.Path.Companion.toPath
import javax.inject.Inject

class GeoDataLayerDatabase(
    private val context: Context
) {

    fun writeLayer(layer: GeoDataLayerLocal, key: String) {

        val path = context.filesDir.path.plus("/geoDataLayers/$key.geojson").toPath()

        FileSystem.SYSTEM.write(path) {
            writeUtf8(layer.features.toString())
        }

    }

}