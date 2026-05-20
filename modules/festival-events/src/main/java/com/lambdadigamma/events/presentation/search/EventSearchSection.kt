package com.lambdadigamma.events.presentation.search

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import kotlinx.parcelize.Parcelize
import java.util.Date

@Immutable
@Parcelize
data class EventSearchSection(
    val range: Pair<Date, Date>? = null,
    val events: List<EventDisplayable>,
    val isUndated: Boolean = false,
) : Parcelable
