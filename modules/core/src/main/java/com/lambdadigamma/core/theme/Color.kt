package com.lambdadigamma.core.theme

import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.ui.graphics.Color

var white = Color(0xFFFFFFFF)
var black = Color(0xFF000000)
var transparent = Color(0x00000000)

var gray50 = Color(0xFFFAFAFA)
var gray100 = Color(0xFFF5F5F5)
var gray200 = Color(0xFFEEEEEE)
var gray300 = Color(0xFFE0E0E0)
var gray400 = Color(0xFFBDBDBD)
var gray500 = Color(0xFF9E9E9E)
var gray600 = Color(0xFF757575)
var gray700 = Color(0xFF616161)
var gray800 = Color(0xFF424242)
var gray900 = Color(0xFF212121)

var yellow50 = Color(0xFFFFFDE7)
var yellow100 = Color(0xFFFFF9C4)
var yellow200 = Color(0xFFFFF59D)
var yellow300 = Color(0xFFFFF176)
var yellow400 = Color(0xFFFFEE58)
var yellow500 = Color(0xFFFFEB3B)
var yellow600 = Color(0xFFFDD835)
var yellow700 = Color(0xFFFBC02D)
var yellow800 = Color(0xFFF9A825)
var yellow900 = Color(0xFFF57F17)

/**
 * Tonal-spot scheme seeded from the yellow of the Moers coat of arms.
 * Used on devices without dynamic color (Android 11 and older).
 */
internal val MoersLightColorScheme = lightColorScheme(
    primary = Color(0xFF6D5E0F),
    onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFF8E287),
    onPrimaryContainer = Color(0xFF534600),
    inversePrimary = Color(0xFFDBC66E),
    secondary = Color(0xFF665E40),
    onSecondary = Color(0xFFFFFFFF),
    secondaryContainer = Color(0xFFEEE2BC),
    onSecondaryContainer = Color(0xFF4E472A),
    tertiary = Color(0xFF43664E),
    onTertiary = Color(0xFFFFFFFF),
    tertiaryContainer = Color(0xFFC5ECCE),
    onTertiaryContainer = Color(0xFF2C4E38),
    background = Color(0xFFFFF9EE),
    onBackground = Color(0xFF1E1B13),
    surface = Color(0xFFFFF9EE),
    onSurface = Color(0xFF1E1B13),
    surfaceVariant = Color(0xFFEAE2D0),
    onSurfaceVariant = Color(0xFF4B4739),
    surfaceTint = Color(0xFF6D5E0F),
    inverseSurface = Color(0xFF333027),
    inverseOnSurface = Color(0xFFF7F0E2),
    error = Color(0xFFBA1A1A),
    onError = Color(0xFFFFFFFF),
    errorContainer = Color(0xFFFFDAD6),
    onErrorContainer = Color(0xFF93000A),
    outline = Color(0xFF7C7767),
    outlineVariant = Color(0xFFCDC6B4),
    scrim = Color(0xFF000000),
    surfaceBright = Color(0xFFFFF9EE),
    surfaceDim = Color(0xFFE0D9CC),
    surfaceContainerLowest = Color(0xFFFFFFFF),
    surfaceContainerLow = Color(0xFFFAF3E5),
    surfaceContainer = Color(0xFFF4EDDF),
    surfaceContainerHigh = Color(0xFFEEE8DA),
    surfaceContainerHighest = Color(0xFFE8E2D4),
)

internal val MoersDarkColorScheme = darkColorScheme(
    primary = Color(0xFFDBC66E),
    onPrimary = Color(0xFF3A3000),
    primaryContainer = Color(0xFF534600),
    onPrimaryContainer = Color(0xFFF8E287),
    inversePrimary = Color(0xFF6D5E0F),
    secondary = Color(0xFFD1C6A1),
    onSecondary = Color(0xFF363016),
    secondaryContainer = Color(0xFF4E472A),
    onSecondaryContainer = Color(0xFFEEE2BC),
    tertiary = Color(0xFFA9D0B3),
    onTertiary = Color(0xFF143723),
    tertiaryContainer = Color(0xFF2C4E38),
    onTertiaryContainer = Color(0xFFC5ECCE),
    background = Color(0xFF15130B),
    onBackground = Color(0xFFE8E2D4),
    surface = Color(0xFF15130B),
    onSurface = Color(0xFFE8E2D4),
    surfaceVariant = Color(0xFF4B4739),
    onSurfaceVariant = Color(0xFFCDC6B4),
    surfaceTint = Color(0xFFDBC66E),
    inverseSurface = Color(0xFFE8E2D4),
    inverseOnSurface = Color(0xFF333027),
    error = Color(0xFFFFB4AB),
    onError = Color(0xFF690005),
    errorContainer = Color(0xFF93000A),
    onErrorContainer = Color(0xFFFFDAD6),
    outline = Color(0xFF969080),
    outlineVariant = Color(0xFF4B4739),
    scrim = Color(0xFF000000),
    surfaceBright = Color(0xFF3C3930),
    surfaceDim = Color(0xFF15130B),
    surfaceContainerLowest = Color(0xFF100E07),
    surfaceContainerLow = Color(0xFF1E1B13),
    surfaceContainer = Color(0xFF222017),
    surfaceContainerHigh = Color(0xFF2D2A21),
    surfaceContainerHighest = Color(0xFF38352B),
)
