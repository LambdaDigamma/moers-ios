package com.lambdadigamma.events.data.mapper

import com.lambdadigamma.events.data.local.model.PlaceCached
import com.lambdadigamma.events.data.remote.model.Place

fun PlaceCached.toDomainModel() = Place(
    id = id,
    lat = lat,
    lng = lng,
    name = name,
    streetName = streetName,
    streetNumber = streetNumber,
    streetAddition = streetAddition,
    postalCode = postalCode,
    postalTown = postalTown,
    countryCode = countryCode,
    tags = tags,
    url = url,
    phone = phone,
    pageID = pageID,
    validatedAt = validatedAt,
    createdAt = createdAt,
    updatedAt = updatedAt,
    deletedAt = deletedAt,
)

fun Place.toEntity() = PlaceCached(
    id = id,
    lat = lat,
    lng = lng,
    name = name,
    streetName = streetName,
    streetNumber = streetNumber,
    streetAddition = streetAddition,
    postalCode = postalCode,
    postalTown = postalTown,
    countryCode = countryCode,
    tags = tags,
    url = url,
    phone = phone,
    pageID = pageID,
    validatedAt = validatedAt,
    createdAt = createdAt,
    updatedAt = updatedAt,
    deletedAt = deletedAt,
)