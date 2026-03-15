package com.lambdadigamma.map.presentation.composable

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Search
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.Dp
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
    onShowPlace: (Long) -> Unit,
    minContentHeight: Dp,
    modifier: Modifier = Modifier,
) {
    var query by rememberSaveable { mutableStateOf("") }

    val filteredPlaces = uiState.places.filter { place ->
        query.matches(place.name, place.addressLine1)
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

    val resultsMinHeight = (minContentHeight - 68.dp).coerceAtLeast(200.dp)

    Column(
        modifier = modifier
            .heightIn(min = minContentHeight)
            .padding(horizontal = 12.dp, vertical = 4.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        TextField(
            value = query,
            onValueChange = { query = it },
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp),
            leadingIcon = {
                Icon(
                    imageVector = Icons.Rounded.Search,
                    contentDescription = null,
                )
            },
            placeholder = { Text(stringResource(R.string.map_drawer_search_placeholder)) },
            singleLine = true,
            shape = MaterialTheme.shapes.large,
            colors = TextFieldDefaults.colors(
                focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.55f),
                unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
                disabledContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent,
                disabledIndicatorColor = Color.Transparent,
            ),
        )

        LazyColumn(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = resultsMinHeight),
            contentPadding = PaddingValues(bottom = 96.dp),
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
                        onClick = { onShowPlace(place.id) },
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
        modifier = Modifier.padding(top = 4.dp, bottom = 2.dp),
    )
}

@Composable
private fun DrawerPlaceItem(
    place: FestivalMapPlace,
    onClick: () -> Unit,
) {
    ListItem(
        headlineContent = {
            Text(
                text = place.name,
                style = MaterialTheme.typography.bodyLarge,
            )
        },
        supportingContent = {
            place.addressLine1
                .takeIf { it.isNotBlank() }
                ?.let { addressLine ->
                    Text(
                        text = addressLine,
                        style = MaterialTheme.typography.bodyMedium,
                    )
                }
        },
        modifier = Modifier.clickable(onClick = onClick),
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
    )

    HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)
}

@Composable
private fun DrawerFeatureItem(
    feature: FestivalMapFeature,
    selected: Boolean,
    onClick: () -> Unit,
) {
    ListItem(
        headlineContent = {
            Text(
                text = feature.name
                    ?.takeIf { it.isNotBlank() }
                    ?: stringResource(R.string.map_drawer_unnamed_booth),
                style = MaterialTheme.typography.bodyLarge,
                color = if (selected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface,
            )
        },
        supportingContent = {
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
                        maxLines = 1,
                    )
                }
        },
        modifier = Modifier.clickable(onClick = onClick),
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
    )

    HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant)
}

private fun String.matches(vararg values: String?): Boolean {
    if (isBlank()) return true
    val query = trim().lowercase()
    return values.any { value ->
        value?.lowercase()?.contains(query) == true
    }
}
