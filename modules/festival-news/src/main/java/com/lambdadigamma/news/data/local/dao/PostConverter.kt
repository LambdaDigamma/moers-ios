package com.lambdadigamma.news.data.local.dao

import androidx.room.TypeConverter
import com.google.gson.GsonBuilder
import com.lambdadigamma.events.data.local.model.EventExtras
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerDeserializer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerSerializer
import com.lambdadigamma.news.data.local.models.PostExtras

class PostConverter {

    @TypeConverter
    fun fromJson(json: String): PostExtras {
        return GsonBuilder()
            .create()
            .fromJson(json, PostExtras::class.java)
    }

    @TypeConverter
    fun toJson(extras: PostExtras): String {
        return GsonBuilder()
            .create()
            .toJson(extras)
    }

}