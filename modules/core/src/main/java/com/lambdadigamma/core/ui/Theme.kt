package com.lambdadigamma.core.ui

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

@Composable
fun MoersFestivalTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit,
) {
    val colorScheme = pickColorScheme(
        darkTheme = darkTheme,
        dynamicColor = dynamicColor,
    )

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            WindowCompat.getInsetsController(window, view).apply {
                isAppearanceLightStatusBars = !darkTheme
                isAppearanceLightNavigationBars = !darkTheme
            }
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content,
    )
}

@Composable
fun pickColorScheme(
    darkTheme: Boolean,
    dynamicColor: Boolean = true,
): ColorScheme = when {
    dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && darkTheme -> {
        dynamicDarkColorScheme(LocalContext.current)
    }
    dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
        dynamicLightColorScheme(LocalContext.current)
    }
    darkTheme -> darkColorScheme()
    else -> lightColorScheme()
}
