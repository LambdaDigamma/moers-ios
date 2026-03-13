package com.lambdadigamma.news.data.local.models

import androidx.room.Entity
import com.google.gson.annotations.SerializedName

@Entity(tableName = "post_extras")
data class PostExtras(
    @SerializedName("cta") var cta: String? = null,
    @SerializedName("type") var type: String? = null
)