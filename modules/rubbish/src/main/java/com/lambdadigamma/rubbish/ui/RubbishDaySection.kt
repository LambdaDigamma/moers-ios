package com.lambdadigamma.rubbish.ui

import android.os.Build
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.DateUtils
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.rubbish.RubbishCollectionItem
import com.lambdadigamma.rubbish.RubbishWasteType
import java.time.format.FormatStyle
import java.util.*

@Composable
fun RubbishDaySection(date: Date, items: List<RubbishCollectionItem>) {

    val formatted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        DateUtils.format(date, FormatStyle.FULL)
    } else {
        DateUtils.format(date, FormatStyle.valueOf("YYYY-mm-dd"))
    }

    Column(
        verticalArrangement = Arrangement.spacedBy(12.dp),
        modifier = Modifier
            .background(MaterialTheme.colorScheme.background)
            .padding(horizontal = 12.dp),
    ) {
        Row(modifier = Modifier.fillMaxWidth()) {
            Text(text = formatted, fontWeight = FontWeight.SemiBold)
        }
        for (item in items) {
            RubbishRow(item = item)
        }
    }

}

@Preview
@Composable
fun RubbishDaySection_Preview() {
    MeinMoersTheme {
        RubbishDaySection(
            date = Date(),
            items = listOf(
                RubbishCollectionItem(1, "2022-05-02", RubbishWasteType.RESIDUAL),
                RubbishCollectionItem(2, "2022-05-02", RubbishWasteType.ORGANIC),
            )
        )
    }
}