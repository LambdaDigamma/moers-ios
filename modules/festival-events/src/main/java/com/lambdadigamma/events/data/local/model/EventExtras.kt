package com.lambdadigamma.events.data.local.model

import androidx.room.Entity
import com.google.gson.annotations.SerializedName

@Entity(tableName = "event_extras")
data class EventExtras(
    @SerializedName("open_end") var isOpenEnd: Boolean? = null
)