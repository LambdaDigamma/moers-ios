package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.Global
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R

@Composable
fun ContributeInfoCard(modifier: Modifier = Modifier) {
    val uriHandler = LocalUriHandler.current

    ElevatedCard(modifier = modifier) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                stringResource(R.string.onboarding_about_contribute_title),
                style = MaterialTheme.typography.titleLarge,
            )
            Text(
                text = stringResource(R.string.onboarding_about_contribute_text),
                style = MaterialTheme.typography.bodyMedium
            )
            Text(
                text = stringResource(R.string.onboarding_about_contribute_question),
                style = MaterialTheme.typography.titleSmall,
            )
            Text(
                text = stringResource(R.string.onboarding_about_contribute_answer),
                style = MaterialTheme.typography.bodyMedium,
            )
            FilledTonalButton(onClick = { uriHandler.openUri(Global.sourceCodeUrl) }) {
                Text(text = stringResource(R.string.onboarding_about_cta))
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun ContributeInfoCardPreview() {
    MeinMoersTheme {
        ContributeInfoCard(modifier = Modifier.padding(16.dp))
    }
}
