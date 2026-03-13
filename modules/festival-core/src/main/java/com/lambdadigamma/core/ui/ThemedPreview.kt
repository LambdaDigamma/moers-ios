package com.lambdadigamma.core.ui

import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable

@Composable
public fun ThemedPreview(
    darkTheme: Boolean = false,
    content: @Composable () -> Unit
) {
    MoersFestivalTheme(darkTheme = darkTheme) {
        Surface {
            content()
        }
    }
}