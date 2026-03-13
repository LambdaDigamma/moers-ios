package com.lambdadigamma.map.data.di

import com.google.maps.android.data.geojson.GeoJsonParser
import com.lambdadigamma.map.data.local.GeoDataLayerDatabase
import com.lambdadigamma.map.data.model.GeoDataLayerLocal
import com.lambdadigamma.map.data.remote.api.FGDService
import org.json.JSONObject
import javax.inject.Inject

class FGDLoader @Inject constructor(
    val db: GeoDataLayerDatabase
) {

    suspend fun load() {

        for (layer in FGDCollection.Layers.getAll()) {
            load(key = layer)
        }

//        StoreBuilder
//            .from<Key, Network, Output, Local>(fetcher, sourceOfTruth)
//            .converter(converter)
//            .validator(validator)
//            .build(updater, bookkeeper)

    }

//    val fetcher = Fetcher.ofFlow<FGDResourceKey, > {
//        FGDService.fgdService.getFGD(it).string()
//    }

    suspend fun load(key: String) {

        try {

            val data = FGDService.fgdService.getFGD(key).string()

            val json = JSONObject(data)
            val geometry = GeoJsonParser(json).features

            println(GeoJsonParser(json).features)

            db.writeLayer(layer = GeoDataLayerLocal(features = geometry), key = key)

        } catch (e: Exception) {
            e.printStackTrace()
        }


    }


}