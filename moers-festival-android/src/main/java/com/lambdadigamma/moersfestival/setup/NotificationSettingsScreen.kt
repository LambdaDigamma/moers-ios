package com.lambdadigamma.moersfestival.setup

import android.Manifest.permission.POST_NOTIFICATIONS
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.rounded.NotificationsActive
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.R

@Composable
fun NotificationSettingsRoute(
    viewModel: AppSetupViewModel = hiltViewModel(),
    onBack: () -> Unit,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val lifecycleOwner = LocalLifecycleOwner.current

    val notificationPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) {
        viewModel.refreshNotificationState()
    }

    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) {
                viewModel.refreshNotificationState()
            }
        }

        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    val primaryAction = {
        when {
            uiState.notificationPermissionGranted -> {
                viewModel.openSystemNotificationSettings()
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !uiState.notificationPermissionRequested -> {
                viewModel.markNotificationPermissionRequested()
                notificationPermissionLauncher.launch(POST_NOTIFICATIONS)
            }
            else -> {
                viewModel.openSystemNotificationSettings()
            }
        }
    }

    NotificationSettingsScreen(
        uiState = uiState,
        onBack = onBack,
        onPrimaryAction = primaryAction,
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotificationSettingsScreen(
    uiState: AppSetupUiState,
    onBack: () -> Unit,
    onPrimaryAction: () -> Unit,
) {
    val colors = MaterialTheme.colorScheme
    val heroContentColor = colors.onPrimaryContainer

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(text = stringResource(com.lambdadigamma.moersfestival.R.string.info_row_notifications))
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = stringResource(R.string.navigation_back),
                        )
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        brush = Brush.linearGradient(
                            colors = listOf(
                                colors.primaryContainer,
                                colors.tertiaryContainer,
                            ),
                        ),
                        shape = RoundedCornerShape(28.dp),
                    )
                    .padding(24.dp),
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    Surface(
                        color = heroContentColor.copy(alpha = 0.12f),
                        shape = CircleShape,
                    ) {
                        Icon(
                            imageVector = Icons.Rounded.NotificationsActive,
                            contentDescription = null,
                            tint = heroContentColor,
                            modifier = Modifier
                                .padding(14.dp)
                                .size(24.dp),
                        )
                    }

                    Text(
                        text = stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_headline),
                        style = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold),
                        color = heroContentColor,
                    )

                    Text(
                        text = stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_copy),
                        style = MaterialTheme.typography.bodyLarge,
                        color = heroContentColor.copy(alpha = 0.78f),
                    )
                }
            }

            Surface(
                shape = RoundedCornerShape(24.dp),
                color = colors.surfaceVariant.copy(alpha = 0.4f),
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    Text(
                        text = if (uiState.notificationPermissionGranted) {
                            stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_status_enabled)
                        } else {
                            stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_status_disabled)
                        },
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    )

                    Text(
                        text = when {
                            uiState.notificationPermissionGranted && uiState.notificationTopicSubscribed -> {
                                stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_enabled_body)
                            }
                            uiState.notificationPermissionGranted -> {
                                stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_syncing_body)
                            }
                            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                                uiState.notificationPermissionRequested -> {
                                stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_system_body)
                            }
                            else -> {
                                stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_request_body)
                            }
                        },
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )

                    Button(
                        onClick = onPrimaryAction,
                        modifier = Modifier.fillMaxWidth(),
                    ) {
                        if (uiState.isSyncingNotifications) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(16.dp),
                                strokeWidth = 2.dp,
                                color = MaterialTheme.colorScheme.onPrimary,
                            )
                        } else {
                            Text(
                                text = when {
                                    uiState.notificationPermissionGranted -> {
                                        stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_open_system_settings)
                                    }
                                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                                        !uiState.notificationPermissionRequested -> {
                                        stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_enable)
                                    }
                                    else -> {
                                        stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_open_system_settings)
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
