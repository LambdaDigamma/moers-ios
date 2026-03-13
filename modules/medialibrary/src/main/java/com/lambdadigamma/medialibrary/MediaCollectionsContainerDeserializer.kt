package com.lambdadigamma.medialibrary

import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.reflect.TypeToken
import java.lang.reflect.Type

class MediaCollectionsContainerDeserializer: JsonDeserializer<MediaCollectionsContainer> {

    override fun deserialize(
        json: JsonElement?,
        typeOfT: Type?,
        context: JsonDeserializationContext?
    ): MediaCollectionsContainer {

        return if (json == null) {
            MediaCollectionsContainer()
        } else if (json.isJsonArray) {
            MediaCollectionsContainer()
        } else if (json.isJsonObject) {
            val jsonObject = json.asJsonObject
            val collections = mutableMapOf<String, List<Media>>()
            jsonObject.entrySet().forEach { (key, value) ->
                val mediaList = context?.deserialize<List<Media>>(value, object : TypeToken<List<Media>>() {}.type)
                collections[key] = mediaList ?: emptyList()
            }
            return MediaCollectionsContainer(collections)
        } else {
            MediaCollectionsContainer()
        }

    }

}