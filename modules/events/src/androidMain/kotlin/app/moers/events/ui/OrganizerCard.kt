package com.lambdadigamma.events.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.events.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OrganizerCard(organizer: String?, modifier: Modifier = Modifier) {

    ElevatedCard(
        elevation = CardDefaults.elevatedCardElevation(),
        modifier = modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = stringResource(R.string.event_organizer_headline),
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(bottom = 4.dp),
            )
            Text(
                text = organizer ?: stringResource(R.string.event_organizer_unknown),
                fontWeight = FontWeight.Normal,
                style = MaterialTheme.typography.bodyMedium,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun OrganizerCardPreview() {
    MeinMoersTheme {
        OrganizerCard(organizer = "Stadt Moers", modifier = Modifier.padding(16.dp))
    }
}