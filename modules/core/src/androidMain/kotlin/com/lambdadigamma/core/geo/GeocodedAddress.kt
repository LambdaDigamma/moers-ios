package com.lambdadigamma.core.geo

import android.location.Address

data class GeocodedAddress(
    val street: String,
    val houseNumber: String,
    val place: String,
    val postalCode: String,
    val countryCode: String = "DE"
)

fun Address.toGeocodedAddress(): GeocodedAddress {

    return GeocodedAddress(
        street = this.thoroughfare ?: "",
        houseNumber = this.subThoroughfare ?: "",
        place = this.locality ?: "",
        postalCode = this.postalCode ?: "",
        countryCode = this.countryCode ?: "DE"
    )

}