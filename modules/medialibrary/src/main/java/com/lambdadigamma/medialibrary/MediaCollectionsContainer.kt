package com.lambdadigamma.medialibrary

import android.os.Parcelable
import com.google.gson.*
import com.google.gson.annotations.JsonAdapter
import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
import com.lambdadigamma.medialibrary.Media
import kotlinx.parcelize.Parcelize
import java.lang.reflect.Type

@Parcelize
data class MediaCollectionsContainer(
    @JsonAdapter(MediaCollectionsAdapter::class)
    val collections: Map<String, List<Media>> = emptyMap()
): Parcelable {
//    constructor(collections: Map<String, List<Media>> = emptyMap()) : this(collections)

    fun getMedia(key: String = "default"): List<Media> {
        return collections[key] ?: emptyList()
    }

    fun getFirstMedia(key: String = "default"): Media? {
        return getMedia(key).firstOrNull()
    }

    fun allMedia(): List<Media> {
        return collections.values.flatten()
    }

    fun toJson(): String {
        return GsonBuilder().registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsAdapter()).create().toJson(this)
    }

    companion object {
        fun fromJson(json: String): MediaCollectionsContainer {
            val type = object : TypeToken<MediaCollectionsContainer>() {}.type
            return Gson().fromJson(json, type)
        }
    }
}
