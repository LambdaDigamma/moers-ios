package com.lambdadigamma.events.presentation

import android.os.Parcelable
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import kotlinx.parcelize.IgnoredOnParcel
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class EventDisplayable(
    val id: Int,
    val name: String,
    val startDate: Date?,
    val endDate: Date?,
    val place: PlaceDisplayable?,
    val isFavorite: Boolean = false,
    val isOpenEnd: Boolean
) : Parcelable {

    @IgnoredOnParcel
    val dateRange: ClosedRange<Date>? = EventUtilities.dateRange(startDate, endDate)

}
