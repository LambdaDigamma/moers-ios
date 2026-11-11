package com.lambdadigamma.rubbish.dashboard

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.placeholder
import com.lambdadigamma.rubbish.R
import com.lambdadigamma.rubbish.RubbishPickupDay
import com.lambdadigamma.rubbish.RubbishScheduleUiState
import com.lambdadigamma.rubbish.RubbishScheduleViewModel
import com.lambdadigamma.rubbish.RubbishWasteType
import com.lambdadigamma.rubbish.icon
import com.lambdadigamma.rubbish.labelRes
import com.lambdadigamma.rubbish.ui.pickupDayLabel
import java.time.LocalDate

@Composable
fun DashboardRubbishComponent(
    modifier: Modifier = Modifier,
    onChooseStreet: () -> Unit = {},
    onClick: () -> Unit,
) {
    val viewModel: RubbishScheduleViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    DashboardRubbishCard(
        uiState = uiState,
        onClick = onClick,
        onChooseStreet = onChooseStreet,
        modifier = modifier,
    )
}

@Composable
fun DashboardRubbishCard(
    uiState: RubbishScheduleUiState,
    onClick: () -> Unit,
    onChooseStreet: () -> Unit,
    modifier: Modifier = Modifier,
) {
    ElevatedCard(onClick = onClick, modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .clip(shape = RoundedCornerShape(4.dp))
                    .background(MaterialTheme.colorScheme.tertiaryContainer)
            ) {
                Icon(
                    painter = painterResource(id = R.drawable.ic_baseline_recycling_24),
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onTertiaryContainer,
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
        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)

        Column(
            modifier = Modifier.padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            when {
                !uiState.hasStreet -> {
                    Text(
                        text = stringResource(R.string.rubbish_no_street_text),
                        style = MaterialTheme.typography.bodyMedium,
                    )
                    FilledTonalButton(onClick = onChooseStreet) {
                        Text(stringResource(R.string.rubbish_choose_street))
                    }
                }
                uiState.isLoading -> repeat(3) {
                    Text(
                        text = "",
                        modifier = Modifier
                            .fillMaxWidth()
                            .placeholder(visible = true),
                    )
                }
                uiState.days.isEmpty() -> Text(
                    text = stringResource(R.string.rubbish_no_pickups),
                    style = MaterialTheme.typography.bodyMedium,
                )
                else -> uiState.days.take(3).forEach { day -> PickupDayRow(day) }
            }
        }
    }
}

@Composable
private fun PickupDayRow(day: RubbishPickupDay) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(
            text = pickupDayLabel(day.date, short = true),
            style = MaterialTheme.typography.labelLarge,
            modifier = Modifier.width(132.dp),
        )
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            day.types.forEach { type ->
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Image(painterResource(type.icon()), contentDescription = null, modifier = Modifier.size(20.dp))
                    Text(stringResource(type.labelRes()), style = MaterialTheme.typography.bodyMedium)
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun DashboardRubbishCardPreview() {
    val today = LocalDate.now()
    MeinMoersTheme {
        DashboardRubbishCard(
            uiState = RubbishScheduleUiState(
                streetName = "Adlerstraße",
                days = listOf(
                    RubbishPickupDay(today, listOf(RubbishWasteType.RESIDUAL, RubbishWasteType.PAPER)),
                    RubbishPickupDay(today.plusDays(1), listOf(RubbishWasteType.PLASTIC)),
                    RubbishPickupDay(today.plusDays(13), listOf(RubbishWasteType.ORGANIC)),
                ),
                isLoading = false,
            ),
            onClick = {},
            onChooseStreet = {},
            modifier = Modifier.padding(16.dp),
        )
    }
}
