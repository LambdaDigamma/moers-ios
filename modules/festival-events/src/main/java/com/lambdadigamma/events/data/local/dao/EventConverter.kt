package com.lambdadigamma.events.data.local.dao

import androidx.room.TypeConverter
import com.google.gson.GsonBuilder
import com.lambdadigamma.events.data.local.model.EventExtras
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerDeserializer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerSerializer

class EventConverter {

    @TypeConverter
    fun fromJson(json: String): EventExtras {
        return GsonBuilder()
            .create()
            .fromJson(json, EventExtras::class.java)
    }

    @TypeConverter
    fun toJson(extras: EventExtras): String {
        return GsonBuilder()
            .create()
            .toJson(extras)
    }

}