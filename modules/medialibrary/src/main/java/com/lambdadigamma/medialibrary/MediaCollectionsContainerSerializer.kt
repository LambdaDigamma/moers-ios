package com.lambdadigamma.medialibrary

import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.JsonSerializationContext
import com.google.gson.JsonSerializer
import java.lang.reflect.Type

class MediaCollectionsContainerSerializer : JsonSerializer<MediaCollectionsContainer> {

    override fun serialize(
        src: MediaCollectionsContainer?,
        typeOfSrc: Type?,
        context: JsonSerializationContext?
    ): JsonElement {
        val jsonObject = JsonObject()
        src?.collections?.forEach { (key, value) ->
            jsonObject.add(key, context?.serialize(value))
        }
        return jsonObject
    }

}