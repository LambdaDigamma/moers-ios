package com.lambdadigamma.rubbish.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.rubbish.R
import com.lambdadigamma.rubbish.RubbishCollectionItem
import com.lambdadigamma.rubbish.RubbishWasteType
import com.lambdadigamma.rubbish.ui.RubbishRow

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardRubbishComponent(modifier: Modifier = Modifier, onClick: () -> Unit) {

    val viewModel: DashboardRubbishViewModel = hiltViewModel()
    val items by viewModel.rubbishCollectionItems.observeAsState()

    LaunchedEffect(key1 = "dashboard_load_rubbish", block = {
        viewModel.list()
    })

    ElevatedCard(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .defaultMinSize(minHeight = 140.dp)
    ) {

        Row(
            modifier = Modifier.padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .clip(shape = RoundedCornerShape(4.dp))
                    .background(Color.Green)
            ) {
                Icon(
                    painter = painterResource(id = R.drawable.ic_baseline_recycling_24),
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier
                        .size(20.dp)
                        .padding(2.dp)
                )
            }
            Text(
                text = stringResource(R.string.dashboard_rubbish_headline),
                style = MaterialTheme.typography.titleMedium
            )
        }
        Divider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f))

        DashboardRubbishContent(items = items?.data.orEmpty(), modifier = Modifier.padding(12.dp))
    }
}

@Composable
fun DashboardRubbishContent(items: List<RubbishCollectionItem>, modifier: Modifier = Modifier) {

    Column(modifier = modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        for (item in items.take(3)) {
            RubbishRow(item = item)
        }
    }

}

@Preview(showBackground = true)
@Composable
private fun DashboardRubbishComponentPreview() {
    MeinMoersTheme {
        DashboardRubbishContent(
            items = listOf(
                RubbishCollectionItem(
                    id = 1,
                    date = "2022-11-14",
                    type = RubbishWasteType.ORGANIC,
                )
            )
        )
    }
}