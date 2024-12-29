package com.lambdadigamma.moers.onboarding.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.Divider
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

@Composable
fun OnboardingHost(
    shouldScroll: Boolean = true,
    content: @Composable () -> Unit,
    bottomContent: @Composable () -> Unit
) {
    val scrollState = rememberScrollState()

    Column(modifier = Modifier.fillMaxSize()) {

        Column(
            modifier = if (shouldScroll) {
                Modifier
                    .weight(1f)
                    .background(color = MaterialTheme.colorScheme.background)
                    .verticalScroll(scrollState)
            } else Modifier
                .weight(1.0f)
                .background(color = MaterialTheme.colorScheme.background)
        ) {
            content()
        }

        Divider()

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(color = MaterialTheme.colorScheme.background)
                .padding(16.dp)
        ) {
            bottomContent()
        }

    }

}

@Composable
@Preview
fun OnboardingHostPreview() {
    OnboardingHost(content = { /*TODO*/ }) {
    }
}