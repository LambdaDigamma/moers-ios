package com.lambdadigamma.events.presentation.detail.composable

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.geo.Point
import com.lambdadigamma.core.ui.ElevatedNavigationButton
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.events.presentation.detail.PlaceDisplayable

@Composable
fun PlaceInformation(
    place: PlaceDisplayable,
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
) {
    val interactionModifier = if (onClick != null) {
        Modifier
            .clip(MaterialTheme.shapes.medium)
            .clickable(onClick = onClick)
            .padding(vertical = 4.dp)
    } else {
        Modifier
    }

    Column(
        modifier = modifier.then(interactionModifier),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = if (onClick != null) 48.dp else 0.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            BasicText(
                text = place.name,
                modifier = Modifier.weight(1f),
                style = MaterialTheme.typography.bodyLarge
                    .copy(
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onBackground,
                    ),
            )

            if (onClick != null) {
                Icon(
                    imageVector = Icons.AutoMirrored.Rounded.KeyboardArrowRight,
                    contentDescription = null,
                    modifier = Modifier.size(24.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }

        Column(modifier = Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(4.dp)) {

            if (place.addressLine1.trim().isNotBlank()) {
                BasicText(
                    text = place.addressLine1.trim(),
                    style = MaterialTheme.typography.bodyLarge.copy(
                        color = MaterialTheme.colorScheme.onBackground
                    )
                )
            }

            if (place.addressLine2.trim().isNotBlank()) {
                BasicText(
                    text = place.addressLine2.trim(),
                    style = MaterialTheme.typography.bodyLarge.copy(
                        color = MaterialTheme.colorScheme.onBackground
                    )
                )
            }

        }

        if (place.point.latitude != 0.0 && place.point.longitude != 0.0) {
            ElevatedNavigationButton(
                point = place.point
            )
        }


    }

}

@Preview
@Composable
private fun PlaceInformationPreview() {
    MoersFestivalTheme {
        PlaceInformation(
            place = PlaceDisplayable(
                id = 1,
                name = "Place name",
                point = Point(10.0, 10.0),
                addressLine1 = "Address line 1",
                addressLine2 = "Address line 2",
            ),
            modifier = Modifier.padding(16.dp)
        )
    }
}
