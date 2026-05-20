package com.lambdadigamma.events.data.mapper

import com.lambdadigamma.events.data.local.model.EventSearchIndexCached
import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.events.data.search.EventSearchTextNormalizer

fun Event.toSearchIndexCached(): EventSearchIndexCached {
    return EventSearchIndexCached(
        eventId = id,
        normalizedName = EventSearchTextNormalizer.normalize(name),
        normalizedArtists = EventSearchTextNormalizer.normalize(artists.orEmpty().joinToString(" ")),
        normalizedPlaceName = EventSearchTextNormalizer.normalize(place?.name.orEmpty()),
    )
}
