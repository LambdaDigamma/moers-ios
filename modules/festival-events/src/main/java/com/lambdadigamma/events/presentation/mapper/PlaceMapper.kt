package com.lambdadigamma.events.presentation.mapper

import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.events.data.remote.model.Place
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable

fun Place.toPresentationModel() = PlaceDisplayable(
    id = id,
    name = name,
    point = Point(lat, lng),
    addressLine1 = (streetName ?: "") + " " + (streetNumber ?: "").trim(),
    addressLine2 = (postalCode ?: "") + " " + (postalTown ?: "").trim()
)