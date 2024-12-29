package com.lambdadigamma.core.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

private val DarkColorPalette = darkColorScheme(
//    background = black,
//    primary = yellow500,
////    primaryVariant = yellow500,
//    secondary = gray900,
//    onPrimary = black,
//    onBackground = white
)

private val LightColorPalette = lightColorScheme(
    background = white,

    primary = black,
//    primaryVariant = black,
    secondary = gray500,
//    onPrimary = white,

    /* Other default colors to override
    background = Color.White,
    surface = Color.White,
    onPrimary = Color.White,
    onSecondary = Color.Black,
    onBackground = Color.Black,
    onSurface = Color.Black,
    */
)

@Composable
fun MeinMoersTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable() () -> Unit) {

    val dynamicColor = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
    val colorScheme = when {
        dynamicColor && darkTheme -> dynamicDarkColorScheme(LocalContext.current)
        dynamicColor && !darkTheme -> dynamicLightColorScheme(LocalContext.current)
        darkTheme -> DarkColorPalette
        else -> LightColorPalette
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}