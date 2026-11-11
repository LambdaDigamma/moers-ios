package com.lambdadigamma.moers.settings

import android.text.format.DateFormat
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.LargeTopBar
import com.lambdadigamma.core.user.UserType
import com.lambdadigamma.fuel.data.FuelType
import com.lambdadigamma.moers.BuildConfig
import com.lambdadigamma.moers.R
import java.util.Calendar

@Composable
fun SettingsScreen(onBack: () -> Unit) {
    val viewModel: SettingsViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    SettingsContent(
        uiState = uiState,
        onBack = onBack,
        onUpdateUserType = viewModel::updateUserType,
        onUpdateFuelType = viewModel::updateFuelType,
    )
}

private enum class SettingsDialog { UserType, FuelType }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsContent(
    uiState: SettingsUiState,
    onBack: () -> Unit,
    onUpdateUserType: (UserType) -> Unit,
    onUpdateFuelType: (FuelType) -> Unit,
) {
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()
    var dialog by rememberSaveable { mutableStateOf<SettingsDialog?>(null) }

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            LargeTopBar(
                title = stringResource(R.string.settings),
                scrollBehavior = scrollBehavior,
                onBack = onBack,
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .verticalScroll(rememberScrollState())
        ) {
            SettingsHeader(stringResource(R.string.settings_user_header))
            ListItem(
                headlineContent = { Text(stringResource(R.string.settings_user_type)) },
                supportingContent = { Text(stringResource(uiState.userType.labelRes())) },
                modifier = Modifier.clickable { dialog = SettingsDialog.UserType },
            )

            SettingsHeader(stringResource(R.string.settings_fuel_header))
            ListItem(
                headlineContent = { Text(stringResource(R.string.settings_fuel_type_label)) },
                supportingContent = { Text(uiState.fuelType.localizedName()) },
                modifier = Modifier.clickable { dialog = SettingsDialog.FuelType },
            )

            if (uiState.userType == UserType.CITIZEN) {
                SettingsHeader(stringResource(R.string.settings_rubbish_header))
                ListItem(
                    headlineContent = { Text(stringResource(R.string.settings_rubbish_street)) },
                    supportingContent = {
                        Text(uiState.rubbishStreetName ?: stringResource(R.string.settings_rubbish_street_unset))
                    },
                )
                ListItem(
                    headlineContent = { Text(stringResource(R.string.settings_rubbish_reminder_time)) },
                    supportingContent = {
                        Text(
                            if (uiState.remindersEnabled) {
                                stringResource(
                                    R.string.settings_rubbish_reminder_time_summary,
                                    formatTime(uiState.reminderHours, uiState.reminderMinutes),
                                )
                            } else {
                                stringResource(R.string.settings_rubbish_reminder_off)
                            }
                        )
                    },
                )
            }

            Text(
                text = stringResource(R.string.settings_version, BuildConfig.VERSION_NAME),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(16.dp),
            )
        }
    }

    when (dialog) {
        SettingsDialog.UserType -> SingleChoiceDialog(
            title = stringResource(R.string.settings_user_type),
            options = UserType.entries,
            selected = uiState.userType,
            label = { stringResource(it.labelRes()) },
            onSelect = onUpdateUserType,
            onDismiss = { dialog = null },
        )
        SettingsDialog.FuelType -> SingleChoiceDialog(
            title = stringResource(R.string.settings_fuel_type_label),
            options = FuelType.entries,
            selected = uiState.fuelType,
            label = { it.localizedName() },
            onSelect = onUpdateFuelType,
            onDismiss = { dialog = null },
        )
        null -> Unit
    }
}

@Composable
private fun SettingsHeader(text: String) {
    Text(
        text = text,
        style = MaterialTheme.typography.titleSmall,
        color = MaterialTheme.colorScheme.primary,
        modifier = Modifier.padding(start = 16.dp, end = 16.dp, top = 24.dp, bottom = 8.dp),
    )
}

@Composable
private fun <T> SingleChoiceDialog(
    title: String,
    options: List<T>,
    selected: T,
    label: @Composable (T) -> String,
    onSelect: (T) -> Unit,
    onDismiss: () -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title) },
        text = {
            Column(Modifier.selectableGroup()) {
                options.forEach { option ->
                    ListItem(
                        headlineContent = { Text(label(option)) },
                        leadingContent = { RadioButton(selected = option == selected, onClick = null) },
                        modifier = Modifier.selectable(
                            selected = option == selected,
                            role = Role.RadioButton,
                            onClick = {
                                onSelect(option)
                                onDismiss()
                            },
                        ),
                    )
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) { Text(stringResource(android.R.string.cancel)) }
        },
    )
}

private fun UserType.labelRes(): Int = when (this) {
    UserType.CITIZEN -> R.string.settings_user_type_citizen
    UserType.VISITOR -> R.string.settings_user_type_guest
}

@Composable
private fun formatTime(hours: Int, minutes: Int): String {
    val context = LocalContext.current
    return remember(hours, minutes) {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hours)
            set(Calendar.MINUTE, minutes)
        }
        DateFormat.getTimeFormat(context).format(calendar.time)
    }
}

@Preview
@Composable
private fun SettingsScreenPreview() {
    MeinMoersTheme {
        SettingsContent(
            uiState = SettingsUiState(rubbishStreetName = "Adlerstraße", remindersEnabled = true),
            onBack = {},
            onUpdateUserType = {},
            onUpdateFuelType = {},
        )
    }
}
