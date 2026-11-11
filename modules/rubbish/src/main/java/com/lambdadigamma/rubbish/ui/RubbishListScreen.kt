package com.lambdadigamma.rubbish.ui

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.NotificationsActive
import androidx.compose.material.icons.outlined.Place
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedCard
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.ErrorContent
import com.lambdadigamma.core.ui.LoadingContent
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.rubbish.R
import com.lambdadigamma.rubbish.RubbishPickupDay
import com.lambdadigamma.rubbish.RubbishScheduleUiState
import com.lambdadigamma.rubbish.RubbishScheduleViewModel
import com.lambdadigamma.rubbish.RubbishWasteType
import com.lambdadigamma.rubbish.icon
import com.lambdadigamma.rubbish.labelRes
import com.lambdadigamma.rubbish.notifications.rememberEnableReminders
import kotlinx.coroutines.launch
import java.time.LocalDate

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RubbishListScreen(onBack: () -> Unit, onChangeStreet: () -> Unit) {
    val viewModel: RubbishScheduleViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current
    val deniedMessage = stringResource(R.string.rubbish_notifications_denied)
    val settingsLabel = stringResource(R.string.rubbish_open_settings)

    val enableReminders = rememberEnableReminders(
        onEnable = { viewModel.setRemindersEnabled(true) },
        onDenied = {
            scope.launch {
                val result = snackbarHostState.showSnackbar(deniedMessage, actionLabel = settingsLabel)
                if (result == SnackbarResult.ActionPerformed) {
                    context.startActivity(
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", context.packageName, null))
                    )
                }
            }
        },
    )

    Scaffold(
        topBar = { TopBar(title = stringResource(R.string.rubbish_collection_title), onBack = onBack) },
        snackbarHost = { SnackbarHost(snackbarHostState) },
    ) { padding ->
        PullToRefreshBox(
            isRefreshing = uiState.isRefreshing && !uiState.isLoading,
            onRefresh = viewModel::refresh,
            modifier = Modifier
                .padding(padding)
                .fillMaxSize(),
        ) {
            when {
                !uiState.hasStreet -> NoStreetContent(onChooseStreet = onChangeStreet)
                uiState.isLoading -> LoadingContent()
                uiState.days.isEmpty() && uiState.refreshFailed ->
                    ErrorContent(message = null, onRetry = viewModel::refresh)
                else -> RubbishSchedule(
                    uiState = uiState,
                    onChangeStreet = onChangeStreet,
                    onEnableReminders = enableReminders,
                )
            }
        }
    }
}

@Composable
private fun RubbishSchedule(
    uiState: RubbishScheduleUiState,
    onChangeStreet: () -> Unit,
    onEnableReminders: () -> Unit,
) {
    LazyColumn(contentPadding = PaddingValues(bottom = 24.dp)) {
        item(key = "street") {
            ListItem(
                headlineContent = { Text(uiState.streetName.orEmpty()) },
                leadingContent = { Icon(Icons.Outlined.Place, contentDescription = null) },
                trailingContent = {
                    TextButton(onClick = onChangeStreet) { Text(stringResource(R.string.rubbish_choose_street)) }
                },
            )
        }
        if (!uiState.remindersEnabled) {
            item(key = "reminders") {
                ReminderPrompt(onEnable = onEnableReminders)
            }
        }
        if (uiState.days.isEmpty()) {
            item(key = "empty") {
                Text(
                    text = stringResource(R.string.rubbish_no_pickups),
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(16.dp),
                )
            }
        }
        uiState.days.forEach { day ->
            item(key = "day-${day.date}") {
                Text(
                    text = pickupDayLabel(day.date),
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.padding(start = 16.dp, end = 16.dp, top = 20.dp, bottom = 4.dp),
                )
            }
            items(day.types, key = { type -> "${day.date}-$type" }) { type ->
                WasteTypeRow(type)
            }
        }
    }
}

@Composable
fun WasteTypeRow(type: RubbishWasteType, modifier: Modifier = Modifier) {
    ListItem(
        headlineContent = { Text(stringResource(type.labelRes())) },
        leadingContent = {
            Image(painter = painterResource(type.icon()), contentDescription = null, modifier = Modifier.size(36.dp))
        },
        modifier = modifier,
    )
}

@Composable
private fun ReminderPrompt(onEnable: () -> Unit) {
    OutlinedCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
    ) {
        ListItem(
            headlineContent = { Text(stringResource(R.string.rubbish_reminders_prompt_title)) },
            supportingContent = { Text(stringResource(R.string.rubbish_reminders_prompt_text)) },
            leadingContent = { Icon(Icons.Outlined.NotificationsActive, contentDescription = null) },
        )
        FilledTonalButton(
            onClick = onEnable,
            modifier = Modifier
                .align(Alignment.End)
                .padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
        ) {
            Text(stringResource(R.string.rubbish_reminders_enable))
        }
    }
}

@Composable
fun NoStreetContent(onChooseStreet: () -> Unit, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = stringResource(R.string.rubbish_no_street_title),
            style = MaterialTheme.typography.titleLarge,
            textAlign = TextAlign.Center,
        )
        Text(
            text = stringResource(R.string.rubbish_no_street_text),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        Button(onClick = onChooseStreet) {
            Text(stringResource(R.string.rubbish_choose_street))
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun RubbishSchedulePreview() {
    val today = LocalDate.now()
    MeinMoersTheme {
        RubbishSchedule(
            uiState = RubbishScheduleUiState(
                streetName = "Adlerstraße",
                days = listOf(
                    RubbishPickupDay(today.plusDays(1), listOf(RubbishWasteType.PLASTIC)),
                    RubbishPickupDay(today.plusDays(13), listOf(RubbishWasteType.ORGANIC)),
                    RubbishPickupDay(today.plusDays(14), listOf(RubbishWasteType.RESIDUAL, RubbishWasteType.PAPER)),
                ),
                isLoading = false,
            ),
            onChangeStreet = {},
            onEnableReminders = {},
        )
    }
}
