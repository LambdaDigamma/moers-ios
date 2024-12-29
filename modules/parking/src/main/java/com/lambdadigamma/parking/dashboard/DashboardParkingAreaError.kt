package com.lambdadigamma.parking.dashboard

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.parking.R

@Composable
fun DashboardParkingAreaError(error: String) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(160.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Column(
            verticalArrangement = Arrangement.spacedBy(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                painter = painterResource(id = R.drawable.ic_baseline_error_outline_24),
                contentDescription = null,
                tint = MaterialTheme.colorScheme.secondary
            )
            Text(
                text = error,
                color = MaterialTheme.colorScheme.secondary,
                style = MaterialTheme.typography.bodyMedium
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun DashboardParkingAreaLoadingPreview() {
    MeinMoersTheme {
        DashboardParkingAreaError("Die Daten können momentan nicht geladen werden.")
    }
}