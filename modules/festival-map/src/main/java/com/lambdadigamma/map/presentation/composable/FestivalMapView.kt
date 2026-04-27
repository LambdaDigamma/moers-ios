package com.lambdadigamma.map.presentation.composable

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MapStyleOptions
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.MapUiSettings
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.Polygon
import com.google.maps.android.compose.rememberCameraPositionState
import com.google.maps.android.compose.rememberUpdatedMarkerState
import com.lambdadigamma.map.R
import com.lambdadigamma.map.data.model.FestivalMapCoordinate
import com.lambdadigamma.map.data.model.FestivalMapGeometry
import com.lambdadigamma.map.data.model.FestivalMapLayerType
import com.lambdadigamma.map.presentation.MapIntent
import com.lambdadigamma.map.presentation.MapSelection
import com.lambdadigamma.map.presentation.MapUiState
import kotlin.math.roundToInt

@Composable
internal fun FestivalMapView(
    uiState: MapUiState,
    onIntent: (MapIntent) -> Unit,
    hasLocationPermission: Boolean,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val useDarkMapStyle = MaterialTheme.colorScheme.background.luminance() < 0.5f
    val mapStyleResource = if (useDarkMapStyle) R.raw.map_style_dark else R.raw.map_style
    val mapStyleOptions = remember(context, mapStyleResource) {
        MapStyleOptions.loadRawResourceStyle(context, mapStyleResource)
    }
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(MAP_CENTER, 16f)
    }
    val selectedBooth = (uiState.selection as? MapSelection.Feature)
        ?.takeIf { selection -> selection.value.layerType == FestivalMapLayerType.Dorf }
    val boothMarkerState = selectedBooth?.let { selection ->
        rememberUpdatedMarkerState(position = selection.focusPoint().toLatLng())
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

    LaunchedEffect(uiState.userLocationFocusToken) {
        val point = uiState.userLocation ?: return@LaunchedEffect
        if (uiState.userLocationFocusToken == 0L) {
            return@LaunchedEffect
        }

        cameraPositionState.animate(
            update = CameraUpdateFactory.newLatLngZoom(
                LatLng(point.latitude, point.longitude),
                17.5f,
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
            mapStyleOptions = mapStyleOptions,
            isMyLocationEnabled = hasLocationPermission,
        ),
    ) {
        val markerIcons = rememberMapMarkerIcons()

        selectedBooth?.let { selection ->
            Marker(
                state = boothMarkerState ?: return@let,
                icon = markerIcons.selected,
                zIndex = FestivalMapLayerType.Dorf.zIndex + 1f,
                onClick = {
                    onIntent(MapIntent.SelectFeature(selection.value))
                    true
                },
            )
        }

        uiState.places.forEach { place ->
            val selected = (uiState.selection as? MapSelection.Place)?.value?.id == place.id

            Marker(
                state = rememberUpdatedMarkerState(
                    position = LatLng(place.point.latitude, place.point.longitude),
                ),
                icon = if (selected) markerIcons.selected else markerIcons.place,
                zIndex = if (selected) 2f else 1f,
                onClick = {
                    onIntent(MapIntent.SelectPlace(place))
                    true
                },
            )
        }

        uiState.layers.forEach { layer ->
            val style = layer.type.style(useDarkMapStyle)

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

private data class MapMarkerIcons(
    val place: BitmapDescriptor,
    val selected: BitmapDescriptor,
)

@Composable
private fun rememberMapMarkerIcons(): MapMarkerIcons {
    val colors = MaterialTheme.colorScheme
    val density = LocalDensity.current

    return remember(
        colors.primary,
        colors.onPrimary,
        colors.primaryContainer,
        colors.onPrimaryContainer,
        density,
    ) {
        MapMarkerIcons(
            place = createMapMarkerIcon(
                containerColor = colors.primaryContainer,
                contentColor = colors.onPrimaryContainer,
                strokeColor = colors.primary.copy(alpha = 0.64f),
                density = density.density,
            ),
            selected = createMapMarkerIcon(
                containerColor = colors.primary,
                contentColor = colors.onPrimary,
                strokeColor = colors.primary,
                density = density.density,
            ),
        )
    }
}

private fun createMapMarkerIcon(
    containerColor: Color,
    contentColor: Color,
    strokeColor: Color,
    density: Float,
): BitmapDescriptor {
    val width = markerDp(36f, density).roundToInt()
    val height = markerDp(44f, density).roundToInt()
    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    val centerX = width / 2f
    val top = markerDp(2f, density)
    val scale = (height - top - markerDp(1f, density)) / 20f
    val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = containerColor.toArgb()
        style = Paint.Style.FILL
    }
    val strokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = strokeColor.toArgb()
        style = Paint.Style.STROKE
        strokeWidth = markerDp(1.4f, density)
        strokeJoin = Paint.Join.ROUND
        strokeCap = Paint.Cap.ROUND
    }
    val dotPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = contentColor.toArgb()
        style = Paint.Style.FILL
    }
    fun pathX(value: Float) = centerX + (value - 12f) * scale
    fun pathY(value: Float) = top + (value - 2f) * scale
    val pinPath = Path().apply {
        moveTo(pathX(12f), pathY(2f))
        cubicTo(pathX(8.13f), pathY(2f), pathX(5f), pathY(5.13f), pathX(5f), pathY(9f))
        cubicTo(pathX(5f), pathY(14.25f), pathX(12f), pathY(22f), pathX(12f), pathY(22f))
        cubicTo(pathX(12f), pathY(22f), pathX(19f), pathY(14.25f), pathX(19f), pathY(9f))
        cubicTo(pathX(19f), pathY(5.13f), pathX(15.87f), pathY(2f), pathX(12f), pathY(2f))
        close()
    }

    canvas.drawPath(pinPath, fillPaint)
    canvas.drawPath(pinPath, strokePaint)
    canvas.drawCircle(pathX(12f), pathY(9f), 2.45f * scale, dotPaint)

    return BitmapDescriptorFactory.fromBitmap(bitmap)
}

private fun markerDp(value: Float, density: Float): Float = value * density

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

private fun FestivalMapLayerType.style(darkTheme: Boolean): LayerStyle {
    return if (darkTheme) {
        darkStyle()
    } else {
        lightStyle()
    }
}

private fun FestivalMapLayerType.lightStyle(): LayerStyle {
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

private fun FestivalMapLayerType.darkStyle(): LayerStyle {
    return when (this) {
        FestivalMapLayerType.Surfaces -> LayerStyle(
            fillColor = Color.Transparent,
            strokeColor = Color(0xD6B08A63),
            strokeWidth = 2f,
        )

        FestivalMapLayerType.Camping -> LayerStyle(
            fillColor = Color(0x4039C173),
            strokeColor = Color(0xC039C173),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Stages -> LayerStyle(
            fillColor = Color(0x30E7EAF0),
            strokeColor = Color(0xA6E7EAF0),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Transportation -> LayerStyle(
            fillColor = Color(0x52FFD166),
            strokeColor = Color(0xCCFFD166),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.MedicalService -> LayerStyle(
            fillColor = Color(0x4039C173),
            strokeColor = Color(0xCC39C173),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Tickets -> LayerStyle(
            fillColor = Color(0x405DA8FF),
            strokeColor = Color(0xCC5DA8FF),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Toilets -> LayerStyle(
            fillColor = Color(0x405D7CFF),
            strokeColor = Color(0xCC5D7CFF),
            strokeWidth = 1.5f,
        )

        FestivalMapLayerType.Dorf -> LayerStyle(
            fillColor = Color(0x34E7EAF0),
            strokeColor = Color(0xA6E7EAF0),
            strokeWidth = 1.25f,
        )
    }
}

private val MAP_CENTER = LatLng(51.441712626435596, 6.618580082309781)
