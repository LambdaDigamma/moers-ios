package com.lambdadigamma.map.data

import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.lambdadigamma.map.data.model.FestivalMapCoordinate
import com.lambdadigamma.map.data.model.FestivalMapFeature
import com.lambdadigamma.map.data.model.FestivalMapGeometry
import com.lambdadigamma.map.data.model.FestivalMapLayer
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import javax.inject.Inject

internal class FestivalMapGeoJsonParser @Inject constructor() {

    fun parseLayer(
        type: FestivalMapLayerType,
        rawJson: String,
    ): FestivalMapLayer {
        val root = JsonParser.parseString(rawJson).asJsonObject
        val features = root
            .getAsJsonArray("features")
            ?.mapIndexedNotNull { index, element ->
                parseFeature(
                    type = type,
                    index = index,
                    element = element,
                )
            }
            .orEmpty()

        return FestivalMapLayer(
            type = type,
            features = features,
        )
    }

    private fun parseFeature(
        type: FestivalMapLayerType,
        index: Int,
        element: JsonElement,
    ): FestivalMapFeature? {
        val featureObject = element.asJsonObjectOrNull() ?: return null
        val geometry = parseGeometry(featureObject.getAsJsonObject("geometry")) ?: return null
        val properties = featureObject.getAsJsonObject("properties")

        return FestivalMapFeature(
            id = properties.stringOrNull("id")
                ?: "${type.remoteKey}-$index",
            layerType = type,
            name = properties.stringOrNull("name"),
            featureType = properties.stringOrNull("type"),
            description = properties.stringOrNull("desc"),
            boothNumber = properties.intOrNull("booth_no")
                ?: properties.intOrNull("boothNo"),
            isFood = properties.booleanLikeOrNull("food"),
            geometry = geometry,
        )
    }

    private fun parseGeometry(geometryObject: JsonObject?): FestivalMapGeometry? {
        if (geometryObject == null) return null

        return when (geometryObject.stringOrNull("type")) {
            "Polygon" -> FestivalMapGeometry.Polygon(
                rings = parsePolygonRings(geometryObject.getAsJsonArray("coordinates"))
                    .takeIf { it.isNotEmpty() }
                    ?: return null,
            )

            "MultiPolygon" -> FestivalMapGeometry.MultiPolygon(
                polygons = geometryObject
                    .getAsJsonArray("coordinates")
                    ?.mapNotNull { polygon ->
                        parsePolygonRings(polygon.asJsonArrayOrNull())
                            .takeIf { it.isNotEmpty() }
                    }
                    .orEmpty()
                    .takeIf { it.isNotEmpty() }
                    ?: return null,
            )

            else -> null
        }
    }

    private fun parsePolygonRings(rings: JsonArray?): List<List<FestivalMapCoordinate>> {
        return rings
            ?.mapNotNull { ring ->
                ring.asJsonArrayOrNull()
                    ?.mapNotNull { coordinate ->
                        coordinate.asJsonArrayOrNull()?.toCoordinate()
                    }
                    ?.takeIf { it.size >= 3 }
            }
            .orEmpty()
    }

    private fun JsonArray.toCoordinate(): FestivalMapCoordinate? {
        if (size() < 2) return null

        val longitude = get(0).asDouble
        val latitude = get(1).asDouble

        return FestivalMapCoordinate(
            latitude = latitude,
            longitude = longitude,
        )
    }

    private fun JsonElement.asJsonObjectOrNull(): JsonObject? {
        return if (isJsonObject) asJsonObject else null
    }

    private fun JsonElement.asJsonArrayOrNull(): JsonArray? {
        return if (isJsonArray) asJsonArray else null
    }

    private fun JsonObject?.stringOrNull(key: String): String? {
        val value = this?.get(key) ?: return null
        if (value.isJsonNull) return null

        return value.asString.takeIf { it.isNotBlank() }
    }

    private fun JsonObject?.intOrNull(key: String): Int? {
        val value = this?.get(key) ?: return null
        if (value.isJsonNull) return null

        return runCatching { value.asInt }.getOrNull()
    }

    private fun JsonObject?.booleanLikeOrNull(key: String): Boolean? {
        val value = this?.get(key) ?: return null
        if (value.isJsonNull) return null

        return when {
            value.isJsonPrimitive && value.asJsonPrimitive.isBoolean -> value.asBoolean
            value.isJsonPrimitive && value.asJsonPrimitive.isNumber -> value.asInt == 1
            value.isJsonPrimitive && value.asJsonPrimitive.isString -> {
                when (value.asString.lowercase()) {
                    "true", "1" -> true
                    "false", "0" -> false
                    else -> null
                }
            }

            else -> null
        }
    }
}
