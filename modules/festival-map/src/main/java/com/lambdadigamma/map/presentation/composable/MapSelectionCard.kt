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
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable
import com.lambdadigamma.events.presentation.detail.composable.PlaceInformation
import com.lambdadigamma.map.R
import com.lambdadigamma.map.presentation.MapSelection

@Composable
internal fun MapSelectionCard(
    selection: MapSelection,
    modifier: Modifier = Modifier,
) {
    ElevatedCard(
        modifier = modifier.fillMaxWidth(),
    ) {
        when (selection) {
            is MapSelection.Feature -> {
                val feature = selection.value
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

            is MapSelection.Place -> {
                val place = selection.value
                PlaceInformation(
                    place = PlaceDisplayable(
                        id = place.id,
                        name = place.name,
                        point = Point(
                            latitude = place.point.latitude,
                            longitude = place.point.longitude,
                        ),
                        addressLine1 = place.addressLine1,
                        addressLine2 = place.addressLine2,
                    ),
                    modifier = Modifier.padding(16.dp),
                )
            }
        }
    }
}
