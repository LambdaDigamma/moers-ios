package com.lambdadigamma.map.presentation.composable

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.lambdadigamma.map.R
import com.lambdadigamma.map.data.model.FestivalMapFeature

@Composable
internal fun SelectedFeatureCard(
    feature: FestivalMapFeature,
    modifier: Modifier = Modifier,
) {
    ElevatedCard(
        modifier = modifier.fillMaxWidth(),
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(
                text = feature.name
                    ?.takeIf { it.isNotBlank() }
                    ?: stringResource(feature.layerType.labelResId),
                style = MaterialTheme.typography.titleMedium,
            )

            Text(
                text = stringResource(
                    R.string.map_selected_layer,
                    stringResource(feature.layerType.labelResId),
                ),
                style = MaterialTheme.typography.bodyMedium,
            )

            feature.boothNumber?.let { boothNumber ->
                Text(
                    text = stringResource(R.string.map_selected_booth, boothNumber),
                    style = MaterialTheme.typography.bodyMedium,
                )
            }

            if (feature.isFood == true) {
                Text(
                    text = stringResource(R.string.map_selected_food),
                    style = MaterialTheme.typography.bodyMedium,
                )
            }

            feature.description
                ?.takeIf { it.isNotBlank() }
                ?.let { description ->
                    Text(
                        text = description,
                        style = MaterialTheme.typography.bodyMedium,
                    )
                }
        }
    }
}
