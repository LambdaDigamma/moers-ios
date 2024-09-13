package com.lambdadigamma.core.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.R
import com.lambdadigamma.core.theme.MeinMoersTheme

data class Venue(
    val name: String,
    val firstLine: String,
    val secondLine: String,
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VenueCard(
    address: Venue?,
    onNavigate: (Venue) -> Unit,
    modifier: Modifier = Modifier
) {
    ElevatedCard(
        elevation = CardDefaults.elevatedCardElevation(),
        modifier = modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = stringResource(R.string.event_detail_venue_headline),
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(bottom = 4.dp)
            )
            Text(
                text = address?.name ?: stringResource(R.string.event_detail_venue_unknown),
                style = MaterialTheme.typography.bodyMedium
            )
            Text(text = address?.firstLine ?: "", style = MaterialTheme.typography.bodyMedium)
            Text(text = address?.secondLine ?: "", style = MaterialTheme.typography.bodyMedium)

            OutlinedButton(
                onClick = {
                    address?.let(onNavigate)
                },
                modifier = Modifier.padding(top = 8.dp)
            ) {
                Text(text = stringResource(R.string.start_navigation_action))
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun LocationCardPreview() {
    MeinMoersTheme() {
        VenueCard(
            address = Venue(
                name = "Grafschafter Museum im Moerser Schloss",
                firstLine = "Museumstraße 1",
                secondLine = "47441 Moers"
            ),
            onNavigate = {},
            modifier = Modifier.padding(16.dp)
        )
    }
}