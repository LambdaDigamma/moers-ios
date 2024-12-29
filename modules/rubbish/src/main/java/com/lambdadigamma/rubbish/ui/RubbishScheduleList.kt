package com.lambdadigamma.rubbish.ui

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.DateText
import com.lambdadigamma.rubbish.RubbishCollectionItem
import com.lambdadigamma.rubbish.RubbishWasteType

@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
@Composable
fun RubbishScheduleList(items: List<RubbishCollectionItem>, modifier: Modifier = Modifier) {

    val groupedItems = remember(items) { items.groupBy { it.parsedDate } }

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(bottom = 32.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        groupedItems.forEach { (sectionDate, items) ->
            stickyHeader {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(MaterialTheme.colorScheme.surfaceVariant)
                        .shadow(
//                            ambientColor = MaterialTheme.colorScheme.onSurface,
                            elevation = 0.5.dp
                        ),
                ) {
                    DateText(
                        date = sectionDate,
                        fontWeight = FontWeight.Medium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
                    )
                }
            }
            items(items) { item ->
                RubbishRow(item = item, modifier = Modifier.padding(horizontal = 16.dp))
            }
        }
    }
}

@Preview
@Composable
fun RubbishScheduleList_Preview() {
    MeinMoersTheme {
        RubbishScheduleList(
            items = listOf(
                RubbishCollectionItem(1, "2022-05-02", RubbishWasteType.RESIDUAL),
                RubbishCollectionItem(2, "2022-05-02", RubbishWasteType.ORGANIC),
                RubbishCollectionItem(3, "2022-05-05", RubbishWasteType.PAPER),
                RubbishCollectionItem(4, "2022-05-06", RubbishWasteType.CUTTINGS),
            )
        )
    }
}