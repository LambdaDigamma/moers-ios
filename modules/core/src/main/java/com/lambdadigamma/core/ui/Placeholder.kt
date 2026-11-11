package com.lambdadigamma.core.ui

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.drawOutline
import androidx.compose.ui.semantics.clearAndSetSemantics

/**
 * Replaces the content with a pulsing Material 3 placeholder while [visible] is true.
 */
@Composable
fun Modifier.placeholder(
    visible: Boolean,
    shape: Shape = MaterialTheme.shapes.small,
): Modifier {
    if (!visible) return this
    val color = MaterialTheme.colorScheme.surfaceContainerHighest
    val transition = rememberInfiniteTransition(label = "placeholder")
    val alpha by transition.animateFloat(
        initialValue = 0.5f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(durationMillis = 800), RepeatMode.Reverse),
        label = "placeholderAlpha",
    )
    return this
        .clearAndSetSemantics { }
        .drawWithContent {
            drawOutline(
                outline = shape.createOutline(size, layoutDirection, this),
                color = color,
                alpha = alpha,
            )
        }
}
