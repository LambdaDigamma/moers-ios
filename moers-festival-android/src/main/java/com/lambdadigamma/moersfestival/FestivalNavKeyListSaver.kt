package com.lambdadigamma.moersfestival

import androidx.compose.runtime.saveable.Saver
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString

internal val FestivalNavKeyListSaver: Saver<List<FestivalNavKey>?, String> = Saver(
    save = { stack ->
        stack?.let {
            runCatching {
                FestivalNavigationStateJson.encodeToString(it)
            }.getOrNull()
        }
    },
    restore = { savedState ->
        runCatching {
            FestivalNavigationStateJson.decodeFromString<List<FestivalNavKey>>(savedState)
        }.getOrNull()
    },
)
