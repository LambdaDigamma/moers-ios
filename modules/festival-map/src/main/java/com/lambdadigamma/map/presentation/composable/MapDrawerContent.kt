package com.lambdadigamma.map.presentation.composable

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.lambdadigamma.map.R
import com.lambdadigamma.map.data.model.FestivalMapFeature
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import com.lambdadigamma.map.data.model.FestivalMapPlace
import com.lambdadigamma.map.presentation.MapIntent
import com.lambdadigamma.map.presentation.MapSelection
import com.lambdadigamma.map.presentation.MapUiState

@Composable
internal fun MapDrawerContent(
    uiState: MapUiState,
    onIntent: (MapIntent) -> Unit,
    modifier: Modifier = Modifier,
) {
    var query by rememberSaveable { mutableStateOf("") }

    val filteredPlaces = uiState.places.filter { place ->
        query.matches(place.name, place.addressLine1, place.addressLine2)
    }

    val boothFeatures = uiState.layers
        .firstOrNull { it.type == FestivalMapLayerType.Dorf }
        ?.features
        .orEmpty()
        .filter { feature ->
            query.matches(
                feature.name,
                feature.description,
                feature.boothNumber?.toString(),
            )
        }

    Column(
        modifier = modifier.padding(horizontal = 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        OutlinedTextField(
            value = query,
            onValueChange = { query = it },
            modifier = Modifier.fillMaxWidth(),
            label = { Text(stringResource(R.string.map_drawer_search_label)) },
            placeholder = { Text(stringResource(R.string.map_drawer_search_placeholder)) },
            singleLine = true,
        )

        LazyColumn(
            modifier = Modifier.fillMaxWidth(),
            contentPadding = PaddingValues(bottom = 96.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            if (filteredPlaces.isNotEmpty()) {
                item(key = "places-header") {
                    DrawerSectionTitle(title = stringResource(R.string.map_drawer_places))
                }

                items(
                    items = filteredPlaces,
                    key = { "place-${it.id}" },
                ) { place ->
                    DrawerPlaceItem(
                        place = place,
                        selected = (uiState.selection as? MapSelection.Place)?.value?.id == place.id,
                        onClick = { onIntent(MapIntent.SelectPlace(place)) },
                    )
                }
            }

            if (boothFeatures.isNotEmpty()) {
                item(key = "booths-header") {
                    DrawerSectionTitle(title = stringResource(R.string.map_drawer_booths))
                }

                items(
                    items = boothFeatures,
                    key = { "feature-${it.id}" },
                ) { feature ->
                    DrawerFeatureItem(
                        feature = feature,
                        selected = (uiState.selection as? MapSelection.Feature)?.value?.id == feature.id,
                        onClick = { onIntent(MapIntent.SelectFeature(feature)) },
                    )
                }
            }

            if (filteredPlaces.isEmpty() && boothFeatures.isEmpty()) {
                item(key = "empty-state") {
                    Text(
                        text = stringResource(R.string.map_drawer_empty_state),
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(vertical = 16.dp),
                    )
                }
            }
        }
    }
}

@Composable
private fun DrawerSectionTitle(title: String) {
    Text(
        text = title,
        style = MaterialTheme.typography.titleSmall,
        color = MaterialTheme.colorScheme.primary,
        modifier = Modifier.padding(top = 8.dp, bottom = 4.dp),
    )
}

@Composable
private fun DrawerPlaceItem(
    place: FestivalMapPlace,
    selected: Boolean,
    onClick: () -> Unit,
) {
    DrawerItemContainer(
        selected = selected,
        onClick = onClick,
    ) {
        Text(
            text = place.name,
            style = MaterialTheme.typography.bodyLarge,
        )

        if (place.addressLine1.isNotBlank()) {
            Text(
                text = place.addressLine1,
                style = MaterialTheme.typography.bodyMedium,
            )
        }

        if (place.addressLine2.isNotBlank()) {
            Text(
                text = place.addressLine2,
                style = MaterialTheme.typography.bodyMedium,
            )
        }
    }
}

@Composable
private fun DrawerFeatureItem(
    feature: FestivalMapFeature,
    selected: Boolean,
    onClick: () -> Unit,
) {
    DrawerItemContainer(
        selected = selected,
        onClick = onClick,
    ) {
        Text(
            text = feature.name
                ?.takeIf { it.isNotBlank() }
                ?: stringResource(R.string.map_drawer_unnamed_booth),
            style = MaterialTheme.typography.bodyLarge,
        )

        feature.boothNumber?.let { boothNumber ->
            Text(
                text = stringResource(R.string.map_selected_booth, boothNumber),
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

@Composable
private fun DrawerItemContainer(
    selected: Boolean,
    onClick: () -> Unit,
    content: @Composable ColumnScope.() -> Unit,
) {
    androidx.compose.material3.Surface(
        tonalElevation = if (selected) 4.dp else 0.dp,
        shape = MaterialTheme.shapes.medium,
        color = if (selected) {
            MaterialTheme.colorScheme.secondaryContainer
        } else {
            MaterialTheme.colorScheme.surface
        },
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp),
            content = content,
        )
    }
}

private fun String.matches(vararg values: String?): Boolean {
    if (isBlank()) return true
    val query = trim().lowercase()
    return values.any { value ->
        value?.lowercase()?.contains(query) == true
    }
}
