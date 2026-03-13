package com.lambdadigamma.medialibrary

import androidx.room.TypeConverter
import com.google.gson.GsonBuilder

class MediaDatabaseConverter {

    @TypeConverter
    fun fromJson(json: String): MediaCollectionsContainer {
        return GsonBuilder()
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerDeserializer())
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerSerializer())
            .create()
            .fromJson(json, MediaCollectionsContainer::class.java)
    }

    @TypeConverter
    fun toJson(mediaCollectionsContainer: MediaCollectionsContainer): String {
        return GsonBuilder()
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerDeserializer())
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerSerializer())
            .create()
            .toJson(mediaCollectionsContainer)
    }

}