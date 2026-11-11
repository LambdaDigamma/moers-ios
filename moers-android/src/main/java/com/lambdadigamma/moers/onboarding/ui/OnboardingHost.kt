package com.lambdadigamma.moers.onboarding.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme

/**
 * Layout of an onboarding step: scrollable [content] above a pinned bar with the
 * step's actions ([bottomContent]). The bar stays above the keyboard.
 */
@Composable
fun OnboardingHost(
    shouldScroll: Boolean = true,
    content: @Composable ColumnScope.() -> Unit,
    bottomContent: @Composable ColumnScope.() -> Unit
) {
    Column(modifier = Modifier.fillMaxSize().imePadding()) {
        Column(
            modifier = Modifier
                .weight(1f)
                .then(if (shouldScroll) Modifier.verticalScroll(rememberScrollState()) else Modifier),
            content = content,
        )

        HorizontalDivider()

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            content = bottomContent,
        )
    }
}

@Composable
@Preview(showBackground = true)
private fun OnboardingHostPreview() {
    MeinMoersTheme {
        OnboardingHost(content = { Text("Content", Modifier.padding(16.dp)) }) {
            Text("Actions")
        }
    }
}
