package com.lambdadigamma.core.geo

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.MarkerState
import com.google.maps.android.compose.rememberCameraPositionState

@Composable
fun Map(modifier: Modifier = Modifier) {

    val singapore = LatLng(1.35, 103.87)
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(singapore, 10f)
    }
    GoogleMap(
        modifier = modifier,
        cameraPositionState = cameraPositionState
    ) {
        Marker(
            state = MarkerState(position = singapore),
            title = "Singapore",
            snippet = "Marker in Singapore"
        )
    }

}

@Preview
@Composable
fun MapPreview() {
    Column(modifier = Modifier.size(400.dp, 600.dp)) {
        Map()
    }
}
