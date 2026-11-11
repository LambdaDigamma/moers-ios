package com.lambdadigamma.events.models

import androidx.room.Entity
import androidx.room.PrimaryKey

/** A city event, cached locally. Dates are epoch milliseconds. */
@Entity(tableName = "events")
data class Event(
    @PrimaryKey val id: Int,
    val name: String,
    val startDate: Long?,
    val endDate: Long?,
    val description: String? = null,
    val teaser: String? = null,
    val subtitle: String? = null,
    val url: String? = null,
    val category: String? = null,
    val isOnline: Boolean = false,
    val locationName: String? = null,
    val street: String? = null,
    val postcode: String? = null,
    val city: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val organizerName: String? = null,
    val organizerPhone: String? = null,
    val organizerEmail: String? = null,
    val organizerWebsite: String? = null,
    val imageUrl: String? = null,
    /** False when only the day of the event is known. */
    val showsTime: Boolean = true,
    val isCancelled: Boolean = false,
) {

    /** Postal address lines without the venue name, or `null` when the event has no address. */
    val addressLines: List<String>
        get() = listOfNotNull(
            street?.takeIf { it.isNotBlank() && it != locationName && !it.equals("online", ignoreCase = true) },
            listOfNotNull(postcode, city).joinToString(" ").takeIf { it.isNotBlank() },
        )

    val hasCoordinates: Boolean
        get() = latitude != null && longitude != null
}
