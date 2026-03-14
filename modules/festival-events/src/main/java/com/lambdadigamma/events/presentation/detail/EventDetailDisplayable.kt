package com.lambdadigamma.events.presentation.detail

import android.os.Parcelable
import com.lambdadigamma.events.data.local.model.ScheduleDisplayMode
import com.lambdadigamma.events.presentation.EventUtilities
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.pages.data.remote.model.Page
import com.lambdadigamma.pages.data.remote.model.PageBlock
import kotlinx.parcelize.IgnoredOnParcel
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class EventDetailDisplayable(
    val id: Int,
    val title: String,
    val startDate: Date?,
    val endDate: Date?,
    val artists: List<String>,
    val place: PlaceDisplayable?,
    val mediaCollections: MediaCollectionsContainer = MediaCollectionsContainer(),
    val blocks: List<PageBlock> = emptyList(),
    val isOpenEnd: Boolean,
    val scheduleDisplayMode: ScheduleDisplayMode = ScheduleDisplayMode.DATE_TIME,
    val isFavorite: Boolean = false,
) : Parcelable {

    @IgnoredOnParcel
    val showsDateComponent: Boolean = scheduleDisplayMode.showsDateComponent

    @IgnoredOnParcel
    val showsTimeComponent: Boolean = scheduleDisplayMode.showsTimeComponent

    @IgnoredOnParcel
    val dateRange: ClosedRange<Date>? = if (showsTimeComponent) EventUtilities.dateRange(startDate, endDate) else null

}
