package com.lambdadigamma.rubbish.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.rubbish.*

@Composable
fun RubbishCollectionItemChip(pickupItem: RubbishCollectionItem, modifier: Modifier = Modifier) {

    Row(
        modifier = modifier
            .fillMaxWidth()
            .background(pickupItem.type.backgroundColor())
            .drawBehind {
                val strokeWidth = 4 * density
                val y = size.height

                drawLine(
                    pickupItem.type.color(),
                    Offset(0f, 0f),
                    Offset(0f, y),
                    strokeWidth
                )
            }
    ) {
        Text(
            pickupItem.type.shortName(),
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier
                .padding(horizontal = 4.dp, vertical = 2.dp)
                .padding(start = 4.dp)
        )
    }

}

@Preview
@Composable
fun RubbishCollectionItemChip_Preview() {
    MeinMoersTheme {
        RubbishCollectionItemChip(
            pickupItem = RubbishCollectionItem(1, "2022-05-05", RubbishWasteType.ORGANIC),
            modifier = Modifier.padding(16.dp)
        )
    }
}