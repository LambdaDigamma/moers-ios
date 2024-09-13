package com.lambdadigamma.core.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Sandbox() {

    Column(
        modifier = Modifier
            .background(MaterialTheme.colorScheme.background)
            .padding(16.dp)
            .fillMaxSize()
    ) {
        Text(text = "Label Small", style = MaterialTheme.typography.labelSmall)
        Text(text = "Label Medium", style = MaterialTheme.typography.labelMedium)
        Text(text = "Label Large", style = MaterialTheme.typography.labelLarge)
        Text(text = "Body Small", style = MaterialTheme.typography.bodySmall)
        Text(text = "Body Medium", style = MaterialTheme.typography.bodyMedium)
        Text(text = "Body Large", style = MaterialTheme.typography.bodyLarge)
        Text(text = "Title Small", style = MaterialTheme.typography.titleSmall)
        Text(text = "Title Medium", style = MaterialTheme.typography.titleMedium)
        Text(text = "Title Large", style = MaterialTheme.typography.titleLarge)
        Text(text = "Headline Small", style = MaterialTheme.typography.headlineSmall)
        Text(text = "Headline Medium", style = MaterialTheme.typography.headlineMedium)
        Text(text = "Headline Large", style = MaterialTheme.typography.headlineLarge)
        Text(text = "Display Small", style = MaterialTheme.typography.displaySmall)
        Text(text = "Display Medium", style = MaterialTheme.typography.displayMedium)
        Text(text = "Display Large", style = MaterialTheme.typography.displayLarge)
        Column(
            modifier = Modifier.padding(0.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Card(modifier = Modifier.fillMaxWidth()) {
                Text(text = "Card", Modifier.padding(16.dp))
            }
            ElevatedCard(modifier = Modifier.fillMaxWidth()) {
                Text(text = "Elevated Card", Modifier.padding(16.dp))
            }
            OutlinedCard(modifier = Modifier.fillMaxWidth()) {
                Text(text = "Outlined Card", Modifier.padding(16.dp))
            }
        }
    }


}

@Preview
@Composable
fun PreviewSandbox() {
    MeinMoersTheme {
        Sandbox()
    }
}