package com.lambdadigamma.moers.onboarding.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme

enum class OnboardingStepState {
    NOT_COMPLETE,
    IN_PROGRESS,
    COMPLETE,
    // SKIPPED
}

//data class OnboardingStep(val title: String, val state: OnboardingStepState)

@Composable
fun OnboardingSteps(
    modifier: Modifier = Modifier,
    steps: List<OnboardingStepState> = listOf(
        OnboardingStepState.COMPLETE,
        OnboardingStepState.IN_PROGRESS,
        OnboardingStepState.NOT_COMPLETE,
    )
) {

    val color = MaterialTheme.colorScheme.primary
    val circleSize = 24.dp
    val checkSize = 16.dp
    val borderWidth = 2.dp

    Row(
        horizontalArrangement = Arrangement.SpaceBetween,
        modifier = modifier
            .fillMaxWidth()
//            .background(MaterialTheme.colorScheme.surface)
            .drawBehind {
                val strokeWidth = borderWidth.value * density
                val y = size.height
                val width = size.width

                drawLine(
                    color,
                    Offset(0f + circleSize.toPx(), y / 2),
                    Offset(width - circleSize.toPx(), y / 2),
                    strokeWidth
                )
            }) {

        for (step in steps) {

            when (step) {
                OnboardingStepState.NOT_COMPLETE -> {
                    Box(
                        modifier = Modifier
                            .size(circleSize)
                            .clip(CircleShape)
                            .border(width = borderWidth, color = color, shape = CircleShape)
                            .background(MaterialTheme.colorScheme.background),
                        contentAlignment = Alignment.Center
                    ) {}
                }
                OnboardingStepState.IN_PROGRESS -> {

                    Box(
                        modifier = Modifier
                            .size(circleSize)
                            .clip(CircleShape)
                            .border(width = borderWidth, color = color, shape = CircleShape)
                            .background(MaterialTheme.colorScheme.background),
                        contentAlignment = Alignment.Center
                    ) {

                        Box(
                            modifier = Modifier
                                .size(circleSize / 2)
                                .clip(CircleShape)
                                .background(MaterialTheme.colorScheme.primary),
                            contentAlignment = Alignment.Center
                        ) {}

                    }

                }
                OnboardingStepState.COMPLETE -> {

                    Box(
                        modifier = Modifier
                            .size(circleSize)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.primary),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Default.Check,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.onPrimary,
                            modifier = Modifier.size(checkSize)
                        )
                    }

                }
            }

        }

    }

}

@Preview
@Composable
fun OnboardingStepsPreview() {
    MeinMoersTheme {
        OnboardingSteps(
            modifier = Modifier
        )
    }
}