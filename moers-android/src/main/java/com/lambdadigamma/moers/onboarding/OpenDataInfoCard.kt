package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ElevatedCard
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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OpenDataInfoCard(modifier: Modifier = Modifier) {

    ElevatedCard(modifier = modifier) {

        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {

            Text(
                stringResource(R.string.onboarding_about_open_data_title),
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Medium
            )

            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {

                Text(
                    text = stringResource(R.string.onboarding_about_open_data_intro),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.SemiBold
                )

                Text(
                    text = stringResource(R.string.onboarding_about_open_data_text),
                    style = MaterialTheme.typography.bodyMedium
                )

                Text(
                    text = stringResource(R.string.onboarding_about_open_data_end),
                    style = MaterialTheme.typography.bodyMedium,
                )

            }

        }

    }

}

@Preview(showBackground = true)
@Composable
private fun OpenDataInfoCardPreview() {
    MeinMoersTheme {
        OpenDataInfoCard(modifier = Modifier.padding(16.dp))
    }
}