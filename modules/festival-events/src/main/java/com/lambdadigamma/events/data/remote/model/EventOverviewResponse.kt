package com.lambdadigamma.events.data.remote.model

import com.google.gson.annotations.SerializedName

data class EventOverviewResponse(
    @SerializedName("today_events") val todayEvents: List<Event>,
    @SerializedName("current_long_term_events") val currentLongTermEvents: List<Event>,
)