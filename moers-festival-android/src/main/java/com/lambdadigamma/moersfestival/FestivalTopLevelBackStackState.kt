package com.lambdadigamma.moersfestival

import kotlinx.serialization.Serializable

@Serializable
internal data class FestivalTopLevelBackStackState(
    val startKey: FestivalNavKey,
    val topLevelKey: FestivalNavKey,
    val topLevelStacks: List<FestivalTopLevelStackState>,
)
