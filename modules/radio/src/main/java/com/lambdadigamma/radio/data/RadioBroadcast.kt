package com.lambdadigamma.radio.data

import com.google.gson.annotations.SerializedName
import java.util.*

data class RadioBroadcast(
    @SerializedName("id") val id: Int,
    @SerializedName("uid") val uid: String,
    @SerializedName("title") val title: String,
    @SerializedName("description") val description: String?,
    @SerializedName("starts_at") val startsAt: Date?,
    @SerializedName("ends_at") val endsAt: Date?,
    @SerializedName("url") val url: String?,
    @SerializedName("attach") val attach: String?,
    @SerializedName("created_at") val createdAt: Date?,
    @SerializedName("updated_at") val updatedAt: Date?
)