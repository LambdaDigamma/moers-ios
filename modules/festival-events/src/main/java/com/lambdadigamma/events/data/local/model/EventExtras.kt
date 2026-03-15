package com.lambdadigamma.events.data.local.model

import androidx.room.Entity
import com.google.gson.annotations.SerializedName

enum class ScheduleDisplayMode(val rawValue: String) {
    HIDDEN("hidden"),
    DATE("date"),
    DATE_TIME("date_time");

    val showsDateComponent: Boolean
        get() = this != HIDDEN

    val showsTimeComponent: Boolean
        get() = this == DATE_TIME

    companion object {
        fun from(rawValue: String?): ScheduleDisplayMode? =
            entries.firstOrNull { it.rawValue == rawValue }
    }
}

@Entity(tableName = "event_extras")
data class EventExtras(
    @SerializedName("open_end") var isOpenEnd: Boolean? = null,
    @SerializedName("schedule_display") var scheduleDisplay: String? = null,
    @SerializedName("is_preview") var isPreview: Boolean? = null
) {
    val scheduleDisplayMode: ScheduleDisplayMode?
        get() = ScheduleDisplayMode.from(scheduleDisplay)
}
