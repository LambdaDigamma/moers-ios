package com.lambdadigamma.core.ui

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.ElevatedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import com.lambdadigamma.core.geo.GoogleMapsNavigationProvider
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.theme.MeinMoersTheme

@Composable
fun ElevatedNavigationButton(point: Point, modifier: Modifier = Modifier) {

    val context = LocalContext.current

    ElevatedButton(
        onClick = {
            GoogleMapsNavigationProvider(context).startNavigation(point)
        },
        modifier = modifier
            .fillMaxWidth()
    ) {
//        Text(text = stringResource(R.string.start_navigation_action))
    }
}

@Preview(showBackground = true)
@Composable
private fun ElevatedNavigationButtonPreview() {
    MeinMoersTheme {
        ElevatedNavigationButton(point = Point(10.0, 10.0))
    }
}