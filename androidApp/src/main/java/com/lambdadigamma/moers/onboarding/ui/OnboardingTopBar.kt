package com.lambdadigamma.moers.onboarding.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun OnboardingTopBar(state: OnboardingTopBarUiState) {

//    Card(shape = RectangleShape, elevation = 4.dp) {
    Column(
        modifier = Modifier.statusBarsPadding().padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            stringResource(id = state.title),
            fontWeight = FontWeight.SemiBold,
            style = MaterialTheme.typography.titleLarge
        )
        OnboardingSteps(steps = state.steps)
    }

}

@Composable
@Preview
fun OnboardingTopBarPreview() {
    MeinMoersTheme {
        OnboardingTopBar(
            OnboardingTopBarUiState(
                R.string.onboarding_about_title,
                listOf(
                    OnboardingStepState.COMPLETE,
                    OnboardingStepState.IN_PROGRESS,
                    OnboardingStepState.NOT_COMPLETE,
                )
            )
        )
    }
}