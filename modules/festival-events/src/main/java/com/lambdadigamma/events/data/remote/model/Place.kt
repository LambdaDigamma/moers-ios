package com.lambdadigamma.events.data.remote.model

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.pages.data.remote.model.Page
import java.util.Date

class Place(
    @SerializedName("id") val id: Long,
    @SerializedName("lat") val lat: Double,
    @SerializedName("lng") val lng: Double,
    @SerializedName("name") val name: String,
    @SerializedName("street_name") val streetName: String?,
    @SerializedName("street_number") val streetNumber: String?,
    @SerializedName("address_addition") val streetAddition: String?,
    @SerializedName("postalcode") val postalCode: String?,
    @SerializedName("postal_town") val postalTown: String?,
    @SerializedName("country_code") val countryCode: String?,
    @SerializedName("tags") val tags: String,
    @SerializedName("url") val url: String?,
    @SerializedName("phone") val phone: String?,
    @SerializedName("page_id") val pageID: Long?,
    @SerializedName("validated_at") val validatedAt: Date?,
    @SerializedName("created_at") val createdAt: Date?,
    @SerializedName("updated_at") val updatedAt: Date?,
    @SerializedName("deleted_at") val deletedAt: Date?,
    @SerializedName("events") val events: List<Event> = emptyList()
)