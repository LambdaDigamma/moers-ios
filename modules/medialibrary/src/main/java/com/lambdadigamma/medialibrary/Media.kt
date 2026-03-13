package com.lambdadigamma.medialibrary

import android.os.Parcelable
import androidx.room.Entity
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

@Parcelize
@Entity(tableName = "media")
data class Media(
    @SerializedName("id") val id: Int,
    @SerializedName("model_type") val modelType: String,
    @SerializedName("model_id") val modelId: Int,
    @SerializedName("uuid") val uuid: String?,
    @SerializedName("collection_name") val collectionName: String,
    @SerializedName("name") val name: String,
    @SerializedName("file_name") val fileName: String,
    @SerializedName("full_url") val fullUrl: String?,
    @SerializedName("alt") val alt: String? = null,
    @SerializedName("caption") val caption: String? = null,
    @SerializedName("credits") val credits: String? = null,
) : Parcelable