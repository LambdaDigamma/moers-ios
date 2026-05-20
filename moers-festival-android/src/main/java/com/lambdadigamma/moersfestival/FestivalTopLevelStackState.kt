package com.lambdadigamma.moersfestival

import kotlinx.serialization.Serializable

@Serializable
internal data class FestivalTopLevelStackState(
    val key: FestivalNavKey,
    val stack: List<FestivalNavKey>,
)
