package com.lambdadigamma.moersfestival

import androidx.compose.runtime.saveable.Saver
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString

internal fun festivalTopLevelBackStackSaver(
    startKey: FestivalNavKey,
    topLevelKeys: Set<FestivalNavKey>,
): Saver<FestivalTopLevelBackStack, String> = Saver(
    save = { backStack ->
        runCatching {
            backStack.encodeAsSavedState()
        }.getOrNull()
    },
    restore = { savedState ->
        restoreFestivalTopLevelBackStackFromSavedState(
            savedState = savedState,
            startKey = startKey,
            topLevelKeys = topLevelKeys,
        )
    },
)

internal fun FestivalTopLevelBackStack.encodeAsSavedState(): String {
    return FestivalNavigationStateJson.encodeToString(toSaveState())
}

internal fun restoreFestivalTopLevelBackStackFromSavedState(
    savedState: String,
    startKey: FestivalNavKey,
    topLevelKeys: Set<FestivalNavKey>,
): FestivalTopLevelBackStack {
    val restoredState = runCatching {
        FestivalNavigationStateJson.decodeFromString<FestivalTopLevelBackStackState>(savedState)
    }.getOrNull()

    return FestivalTopLevelBackStack(
        startKey = startKey,
        topLevelKeys = topLevelKeys,
        restoredState = restoredState,
    )
}
