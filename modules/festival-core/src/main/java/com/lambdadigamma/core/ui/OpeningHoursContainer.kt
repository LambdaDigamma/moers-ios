package com.lambdadigamma.core.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.R
import com.lambdadigamma.core.theme.MeinMoersTheme

data class OpeningHoursEntry(val label: String, val value: String)

@Composable
fun OpeningHoursContainer(
    modifier: Modifier = Modifier,
    label: String? = null,
    entries: List<OpeningHoursEntry>
) {

    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(
            text = label ?: stringResource(R.string.opening_hours_headline),
            fontWeight = FontWeight.Bold
        )
        for (entry in entries) {
            OpeningEntryRow(label = entry.label, value = entry.value)
        }
        if (entries.isEmpty()) {
            OpeningEntryRow(label = stringResource(R.string.opening_hours_unknown), value = "")
        }
    }

}

@Composable
fun OpeningEntryRow(label: String, value: String) {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(
            text = label,
            fontWeight = FontWeight.Normal,
            maxLines = 3,
            style = MaterialTheme.typography.bodyMedium,
            modifier = Modifier.weight(0.5f)
        )
        Text(
            text = value,
            fontWeight = FontWeight.Normal,
            style = MaterialTheme.typography.bodyMedium
        )
    }
}

@Preview(showBackground = true)
@Composable
fun OpeningHoursContainerPreview() {

    val entries = listOf(
        OpeningHoursEntry(label = "Mo-Fr", value = "06:00 - 22:30"),
        OpeningHoursEntry(label = "Samstag", value = "07:00 - 22:00"),
        OpeningHoursEntry(label = "Sonntag", value = "08:00 - 22:00")
    )

    MeinMoersTheme {
        OpeningHoursContainer(entries = entries, modifier = Modifier.padding(16.dp))
    }
}