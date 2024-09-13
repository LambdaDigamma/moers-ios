package com.lambdadigamma.core.ui

import androidx.annotation.StringRes
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
//import com.lambdadigamma.core.R
import com.lambdadigamma.core.theme.MeinMoersTheme

@Composable
fun OpenBadge(
    isOpen: Boolean,
    modifier: Modifier = Modifier,
    innerPaddingValues: PaddingValues = PaddingValues(
        horizontal = 12.dp,
        vertical = 8.dp
    ),
    cornerSize: Dp = 4.dp,
) {

    val isOpenBackgroundColor: Color = remember(isOpen) {
        if (isOpen) {
            return@remember Color(0xFF4CAF50)
        } else {
            return@remember Color(0xFFF44336)
        }
    }

    @StringRes
    val isOpenText: Int = remember(isOpen) {
        return@remember 0
//        if (isOpen)
//            return@remember R.string.badge_is_open
//        else {
//            return@remember R.string.badge_is_closed
//        }
    }

    Text(
        text = stringResource(id = isOpenText),
        color = Color.White,
        fontWeight = FontWeight.Medium,
        modifier = modifier
            .clip(RoundedCornerShape(cornerSize))
            .background(isOpenBackgroundColor)
            .padding(innerPaddingValues)
    )

}

@Preview(showBackground = true)
@Composable
private fun OpenBadgePreview() {
    MeinMoersTheme {
        OpenBadge(isOpen = true, modifier = Modifier.padding(8.dp))
    }
}