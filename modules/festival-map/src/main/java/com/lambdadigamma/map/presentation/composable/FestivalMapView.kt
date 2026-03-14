package com.lambdadigamma.map.presentation.composable

import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MapStyleOptions
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.MapUiSettings
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.Polygon
import com.google.maps.android.compose.rememberUpdatedMarkerState
import com.google.maps.android.compose.rememberCameraPositionState
import com.lambdadigamma.map.R
import com.lambdadigamma.map.data.model.FestivalMapCoordinate
import com.lambdadigamma.map.data.model.FestivalMapGeometry
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import com.lambdadigamma.map.presentation.MapIntent
import com.lambdadigamma.map.presentation.MapSelection
import com.lambdadigamma.map.presentation.MapUiState

@Composable
internal fun FestivalMapView(
    uiState: MapUiState,
    onIntent: (MapIntent) -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(MAP_CENTER, 16f)
    }

    LaunchedEffect(uiState.selection?.stableId) {
        val selection = uiState.selection ?: return@LaunchedEffect
        val focusPoint = selection.focusPoint()
        cameraPositionState.animate(
            update = CameraUpdateFactory.newLatLngZoom(
                LatLng(focusPoint.latitude, focusPoint.longitude),
                if (selection is MapSelection.Place) 17f else 18f,
            ),
        )
    }

    GoogleMap(
        modifier = modifier,
        cameraPositionState = cameraPositionState,
        onMapClick = {
            onIntent(MapIntent.ClearSelection)
        },
        uiSettings = MapUiSettings(
            compassEnabled = false,
            indoorLevelPickerEnabled = false,
            mapToolbarEnabled = false,
            myLocationButtonEnabled = false,
        ),
        googleMapOptionsFactory = {
            GoogleMapOptions()
        },
        properties = MapProperties(
            mapStyleOptions = MapStyleOptions.loadRawResourceStyle(context, R.raw.map_style),
        ),
    ) {
        uiState.places.forEach { place ->
            Marker(
                state = rememberUpdatedMarkerState(
                    position = LatLng(place.point.latitude, place.point.longitude),
                ),
                title = place.name,
                snippet = listOf(place.addressLine1, place.addressLine2)
                    .filter { it.isNotBlank() }
                    .joinToString(separator = "\n")
                    .takeIf { it.isNotBlank() },
                icon = BitmapDescriptorFactory.defaultMarker(
                    if ((uiState.selection as? MapSelection.Place)?.value?.id == place.id) {
                        BitmapDescriptorFactory.HUE_ORANGE
                    } else {
                        BitmapDescriptorFactory.HUE_AZURE
                    },
                ),
                onClick = {
                    onIntent(MapIntent.SelectPlace(place))
                    true
                },
            )
        }

        uiState.layers.forEach { layer ->
            val style = layer.type.style()

            layer.features.forEach { feature ->
                feature.geometry.asPolygons().forEach { polygon ->
                    val selected = (uiState.selection as? MapSelection.Feature)?.value?.id == feature.id

                    Polygon(
                        points = polygon.outerRing.map(FestivalMapCoordinate::toLatLng),
                        holes = polygon.holes.map { hole -> hole.map(FestivalMapCoordinate::toLatLng) },
                        clickable = true,
                        fillColor = style.fillColor(selected),
                        strokeColor = style.strokeColor(selected),
                        strokeWidth = style.strokeWidth(selected),
                        zIndex = layer.type.zIndex,
                        onClick = {
                            onIntent(MapIntent.SelectFeature(feature))
                        },
                    )
                }
            }
        }
    }
}

private data class PolygonRings(
    val outerRing: List<FestivalMapCoordinate>,
    val holes: List<List<FestivalMapCoordinate>>,
)

private fun FestivalMapGeometry.asPolygons(): List<PolygonRings> {
    return when (this) {
        is FestivalMapGeometry.Polygon -> listOf(
            PolygonRings(
                outerRing = rings.first(),
                holes = rings.drop(1),
            ),
        )

        is FestivalMapGeometry.MultiPolygon -> polygons.map { polygon ->
            PolygonRings(
                outerRing = polygon.first(),
                holes = polygon.drop(1),
            )
        }
    }
}

private fun FestivalMapCoordinate.toLatLng(): LatLng {
    return LatLng(latitude, longitude)
}

private data class LayerStyle(
    val fillColor: Color,
    val strokeColor: Color,
    val strokeWidth: Float,
) {
    fun fillColor(selected: Boolean): Color {
        return if (selected) fillColor.copy(alpha = (fillColor.alpha + 0.18f).coerceAtMost(0.85f)) else fillColor
    }

    fun strokeColor(selected: Boolean): Color {
        return if (selected) strokeColor.copy(alpha = 1f) else strokeColor
    }

    fun strokeWidth(selected: Boolean): Float {
        return if (selected) strokeWidth + 2f else strokeWidth
    }
}

private fun FestivalMapLayerType.style(): LayerStyle {
    return when (this) {
        FestivalMapLayerType.Surfaces -> LayerStyle(
            fillColor = Color.Transparent,
            strokeColor = Color(0xA6815C38),
            strokeWidth = 2f,
        )

        FestivalMapLayerType.Camping -> LayerStyle(
            fillColor = Color(0x332E7D32),
            strokeColor = Color(0x7A2E7D32),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Stages -> LayerStyle(
            fillColor = Color(0x33111111),
            strokeColor = Color(0x80111111),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Transportation -> LayerStyle(
            fillColor = Color(0x4CF4B400),
            strokeColor = Color(0x99C58F00),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.MedicalService -> LayerStyle(
            fillColor = Color(0x334CAF50),
            strokeColor = Color(0x804CAF50),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Tickets -> LayerStyle(
            fillColor = Color(0x334285F4),
            strokeColor = Color(0x804285F4),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Toilets -> LayerStyle(
            fillColor = Color(0x333E78E0),
            strokeColor = Color(0x803E78E0),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Dorf -> LayerStyle(
            fillColor = Color(0x33111111),
            strokeColor = Color(0x66111111),
            strokeWidth = 1.25f,
        )
    }
}

private val MAP_CENTER = LatLng(51.441712626435596, 6.618580082309781)
