package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme

@Composable
fun OnboardingStreetRow(street: RubbishStreetUiState, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.fillMaxWidth()
    ) {
        Text(street.streetName, fontWeight = FontWeight.Medium)
        street.addition?.let { streetAddition ->
            if (streetAddition.isNotEmpty()) {
                Text(streetAddition, color = MaterialTheme.colorScheme.secondary)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OnboardingStreetRecommendationCard(recommendedStreets: List<RubbishStreetUiState>) {

    Card(modifier = Modifier.fillMaxWidth()) {
        Column(
            modifier = Modifier
        ) {
            Text(
                text = "Vorschlag basierend auf Deinem Standort",
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Medium,
                modifier = Modifier
                    .padding(horizontal = 12.dp)
                    .padding(top = 12.dp, bottom = 12.dp)
            )

            for (street in recommendedStreets) {
                Divider()
                OnboardingStreetRow(
                    street = street,
                    modifier = Modifier
                        .clickable {

                        }
                        .padding(vertical = 8.dp, horizontal = 12.dp)
                )
            }
        }
    }


}

@Preview
@Composable
fun OnboardingStreetRecommendationCard_Preview() {
    MeinMoersTheme {
        OnboardingStreetRecommendationCard(
            listOf(
                RubbishStreetUiState(1, "Bahnhofstrasse", "1-75"),
                RubbishStreetUiState(2, "Bahnhofstrasse", "76-155"),
                RubbishStreetUiState(3, "Bahnhofstrasse", "156-200"),
            )
        )
    }
}