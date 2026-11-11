package com.lambdadigamma.events.models

import com.google.gson.annotations.SerializedName
import java.time.OffsetDateTime
import java.time.format.DateTimeParseException

/** One page of `GET /api/v1/events`. */
data class EventPageResponse(
    val data: List<EventDto>?,
    val meta: EventPageMeta?,
)

data class EventPageMeta(
    @SerializedName("current_page") val currentPage: Int?,
    @SerializedName("last_page") val lastPage: Int?,
    val total: Int?,
)

/** Event as returned by the Mein Moers API. All fields are optional on the wire. */
data class EventDto(
    val id: Int?,
    val name: String?,
    val startDate: String?,
    val endDate: String?,
    val description: String?,
    val teaser: String?,
    val subtitle: String?,
    val url: String?,
    val category: String?,
    val attendanceMode: String?,
    val isOnline: Boolean?,
    val locationName: String?,
    val street: String?,
    val postcode: String?,
    val city: String?,
    val latitude: Double?,
    val longitude: Double?,
    val organisationName: String?,
    val organizerPhone: String?,
    val organizerEmail: String?,
    val organizerWebsite: String?,
    val headerImageUrl: String?,
    val showsTimeComponent: Boolean?,
    val cancelledAt: String?,
) {

    fun toEvent(): Event? {
        val id = id ?: return null
        val name = name?.trim()?.takeIf { it.isNotEmpty() } ?: return null
        return Event(
            id = id,
            name = name,
            startDate = parseDate(startDate),
            endDate = parseDate(endDate),
            description = description?.trim()?.takeIf { it.isNotEmpty() },
            teaser = teaser?.trim()?.takeIf { it.isNotEmpty() },
            subtitle = subtitle?.trim()?.takeIf { it.isNotEmpty() },
            url = url?.takeIf { it.isNotBlank() },
            category = category?.trim()?.takeIf { it.isNotEmpty() },
            isOnline = isOnline == true || attendanceMode.equals("online", ignoreCase = true),
            locationName = locationName?.trim()?.takeIf { it.isNotEmpty() },
            street = street?.trim()?.takeIf { it.isNotEmpty() },
            postcode = postcode?.trim()?.takeIf { it.isNotEmpty() },
            city = city?.trim()?.takeIf { it.isNotEmpty() },
            latitude = latitude,
            longitude = longitude,
            organizerName = organisationName?.trim()?.takeIf { it.isNotEmpty() },
            organizerPhone = organizerPhone?.trim()?.takeIf { it.isNotEmpty() },
            organizerEmail = organizerEmail?.trim()?.takeIf { it.isNotEmpty() },
            organizerWebsite = organizerWebsite?.takeIf { it.isNotBlank() },
            imageUrl = headerImageUrl?.takeIf { it.isNotBlank() },
            showsTime = showsTimeComponent != false,
            isCancelled = cancelledAt != null,
        )
    }

    private fun parseDate(value: String?): Long? = try {
        value?.let { OffsetDateTime.parse(it).toInstant().toEpochMilli() }
    } catch (_: DateTimeParseException) {
        null
    }
}
