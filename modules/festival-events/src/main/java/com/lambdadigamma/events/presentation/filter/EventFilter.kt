package com.lambdadigamma.events.presentation.filter

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class EventFilter(
    val venueIds: List<Long> = emptyList(),
    val showOnlyFavorites: Boolean = false,
) : Parcelable {
    val isEmpty: Boolean
        get() = venueIds.isEmpty() && !showOnlyFavorites

    fun toggledVenue(venueId: Long): EventFilter {
        val updatedVenueIds = venueIds.toMutableList().apply {
            if (contains(venueId)) {
                remove(venueId)
            } else {
                add(venueId)
            }
        }.distinct().sorted()

        return copy(venueIds = updatedVenueIds)
    }
}

@Parcelize
data class EventVenueFilterOption(
    val id: Long,
    val name: String,
) : Parcelable
