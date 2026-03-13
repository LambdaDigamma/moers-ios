package com.lambdadigamma.medialibrary

import com.google.gson.GsonBuilder
import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.JsonSerializationContext
import com.google.gson.JsonSerializer
import com.google.gson.reflect.TypeToken
import java.lang.reflect.Type

class MediaCollectionsAdapter : JsonSerializer<MediaCollectionsContainer>,
    JsonDeserializer<MediaCollectionsContainer> {
    override fun serialize(
        src: MediaCollectionsContainer?,
        typeOfSrc: Type?,
        context: JsonSerializationContext?
    ): JsonElement {
        val gson = GsonBuilder().create()
        val jsonObject = JsonObject()
        src?.collections?.forEach { (key, value) ->
            jsonObject.add(key, gson.toJsonTree(value))
        }
        return jsonObject
    }

    override fun deserialize(
        json: JsonElement?,
        typeOfT: Type?,
        context: JsonDeserializationContext?
    ): MediaCollectionsContainer {
        val gson = GsonBuilder().create()
        val jsonObject = json?.asJsonObject
        return if (jsonObject != null && jsonObject.isJsonObject) {
            val map = mutableMapOf<String, List<Media>>()
            for ((key, value) in jsonObject.entrySet()) {
                val mediaList = gson.fromJson<List<Media>>(value, object : TypeToken<List<Media>>() {}.type)
                map[key] = mediaList
            }
            MediaCollectionsContainer(map)
        } else {
            MediaCollectionsContainer()
        }
    }
}