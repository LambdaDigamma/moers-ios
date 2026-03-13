package com.lambdadigamma.map.presentation.composable

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MapStyleOptions
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.MapUiSettings
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.MarkerState
import com.google.maps.android.compose.Polygon
import com.google.maps.android.compose.rememberCameraPositionState
import com.google.maps.android.data.geojson.GeoJsonLayer
import com.google.maps.android.data.geojson.GeoJsonParser
import com.lambdadigamma.map.R

@Composable
fun Map(modifier: Modifier = Modifier) {

    val center = LatLng(51.441712626435596, 6.618580082309781)
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(center, 15f)
    }

    val context = LocalContext.current



    GoogleMap(
        modifier = modifier,
        cameraPositionState = cameraPositionState,
        uiSettings = MapUiSettings(),
        googleMapOptionsFactory = {
            GoogleMapOptions()
                .apply {

                }
        },
        properties = MapProperties(
            mapStyleOptions = MapStyleOptions.loadRawResourceStyle(context, R.raw.map_style),
        ),
    ) {
        Marker(
            state = MarkerState(position = center),
            title = "Singapore",
            snippet = "Marker in Singapore"
        )

        Polygon(points = listOf(
            LatLng(51.4402804, 6.619086),
            LatLng(51.4403553, 6.6188498),
            LatLng(51.440143, 6.6186772),
            LatLng(51.4400723, 6.6189103),
        ))
    }

}

@Preview
@Composable
fun MapPreview() {
    Column(modifier = Modifier.size(400.dp, 600.dp)) {
        Map()
    }
}
