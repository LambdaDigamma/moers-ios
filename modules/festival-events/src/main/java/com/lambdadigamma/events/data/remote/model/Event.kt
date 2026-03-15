package com.lambdadigamma.events.data.remote.model

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.events.data.local.model.EventExtras
import com.lambdadigamma.events.data.local.model.ScheduleDisplayMode
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.pages.data.remote.model.Page
import java.util.Date

data class Event(

    @SerializedName("id") var id: Int = 0,

    @SerializedName("name") var name: String = "",
    @SerializedName("description") var description: String? = null,

    @SerializedName("start_date") var startDate: Date? = null,
    @SerializedName("end_date") var endDate: Date? = null,

    @SerializedName("page_id") var pageId: Int? = null,
    @SerializedName("place_id") var placeId: Int? = null,

    @SerializedName("url") var url: String? = null,
    @SerializedName("category") var category: String? = null,
    @SerializedName("collection") var collection: String? = null,

    @SerializedName("place") var place: Place? = null,
    @SerializedName("page") var page: Page? = null,

    @SerializedName("extras") var extras: EventExtras? = null,

    @SerializedName("published_at") var publishedAt: Date? = null,
    @SerializedName("cancelled_at") var cancelledAt: Date? = null,
    @SerializedName("scheduled_at") var scheduledAt: Date? = null,
    @SerializedName("created_at") var createdAt: Date? = Date(),
    @SerializedName("updated_at") var updatedAt: Date? = Date(),
    @SerializedName("archived_at") var archivedAt: Date? = null,
    @SerializedName("deleted_at") var deletedAt: Date? = null,

    @SerializedName("artists") var artists: List<String>? = null,

    @SerializedName("media_collections") var mediaCollections: MediaCollectionsContainer = MediaCollectionsContainer(),

    @SerializedName("is_favorite") var isFavorite: Boolean? = null

) {

    val isOpenEnd: Boolean
        get() {
            return extras?.isOpenEnd ?: false
        }

    val scheduleDisplayMode: ScheduleDisplayMode
        get() {
            return extras?.scheduleDisplayMode
                ?: if (extras?.isPreview == true) {
                    ScheduleDisplayMode.DATE
                } else {
                    ScheduleDisplayMode.DATE_TIME
                }
        }

    val showsDateComponent: Boolean
        get() = scheduleDisplayMode.showsDateComponent

    val showsTimeComponent: Boolean
        get() = scheduleDisplayMode.showsTimeComponent
}
