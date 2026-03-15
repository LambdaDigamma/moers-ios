package com.lambdadigamma.events.domain.models

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.pages.data.remote.model.Page

data class EventDetailData(
    val event: Event,
    val page: Page?,
    val isFavorite: Boolean = false,
) {


}