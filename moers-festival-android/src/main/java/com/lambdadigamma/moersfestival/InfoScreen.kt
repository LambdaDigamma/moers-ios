package com.lambdadigamma.moersfestival

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.rounded.OpenInNew
import androidx.compose.material.icons.rounded.ContentCopy
import androidx.compose.material.icons.rounded.DownloadForOffline
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.Link
import androidx.compose.material.icons.rounded.NotificationsActive
import androidx.compose.material.icons.rounded.Refresh
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MediumTopAppBar
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.messaging.FirebaseMessaging
import com.lambdadigamma.core.navigation.NavigationCommand
import com.lambdadigamma.core.navigation.NavigationDestination
import com.lambdadigamma.core.navigation.NavigationManager
import com.lambdadigamma.moersfestival.setup.AppSetupViewModel
import java.net.URLEncoder
import java.nio.charset.StandardCharsets

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun InfoScreen(navigationManager: NavigationManager) {
    val setupViewModel: AppSetupViewModel = hiltViewModel()
    val setupUiState by setupViewModel.uiState.collectAsStateWithLifecycle()
    val navigateUrl = { url: String ->
        val encodedUrl = URLEncoder.encode(url, StandardCharsets.UTF_8.toString())
        navigationManager.navigate(object : NavigationCommand {
            override val destination: String = NavigationDestination.Web.route.replace("{url}", encodedUrl)
        })
    }

    InfoScreen(
        onOpenWeb = navigateUrl,
        onOpenDownload = {
            navigationManager.navigate(object : NavigationCommand {
                override val destination: String = NavigationDestination.EventDownload.route
            })
        },
        onOpenNotificationSettings = {
            navigationManager.navigate(object : NavigationCommand {
                override val destination: String = NavigationDestination.NotificationSettings.route
            })
        },
        onOpenAppInformation = {
            navigationManager.navigate(object : NavigationCommand {
                override val destination: String = NavigationDestination.AppInformation.route
            })
        },
        onOpenLicenses = {
            navigationManager.navigate(object : NavigationCommand {
                override val destination: String = NavigationDestination.AppLicenses.route
            })
        },
        showNotificationOptInBanner = !setupUiState.notificationPermissionGranted,
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun InfoScreen(
    onOpenWeb: (String) -> Unit,
    onOpenDownload: () -> Unit,
    onOpenNotificationSettings: () -> Unit,
    onOpenAppInformation: () -> Unit,
    onOpenLicenses: () -> Unit,
    showNotificationOptInBanner: Boolean = false,
) {
    Scaffold(
        topBar = {
            MediumTopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.navigation_info),
                        maxLines = 1,
                    )
                },
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize(),
            contentPadding = PaddingValues(
                top = paddingValues.calculateTopPadding() + 8.dp,
                bottom = paddingValues.calculateBottomPadding() + 24.dp,
            ),
        ) {
            item(key = "intro") {
                InfoIntro()
            }

            if (showNotificationOptInBanner) {
                item(key = "notification-opt-in-banner") {
                    InfoNotificationOptInBanner(onClick = onOpenNotificationSettings)
                }
            }

            item(key = "festival-header") {
                InfoSectionHeader(title = stringResource(R.string.info_section_festival))
            }
            item(key = "festival-download") {
                InfoRow(
                    title = stringResource(com.lambdadigamma.events.R.string.download_timetable),
                    leadingIcon = Icons.Rounded.DownloadForOffline,
                    trailingIcon = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                ) {
                    onOpenDownload()
                }
            }
            item(key = "festival-tickets") {
                InfoRow(title = stringResource(R.string.info_row_tickets)) {
                    onOpenWeb("https://www.moers-festival.de/tickets/")
                }
            }
            item(key = "festival-festivaldorf") {
                InfoRow(title = stringResource(R.string.info_row_festivaldorf)) {
                    onOpenWeb("https://www.moers-festival.de/infos/festivaldorf/")
                }
            }
            item(key = "festival-volunteers") {
                InfoRow(title = stringResource(R.string.info_row_volunteers)) {
                    onOpenWeb("https://www.moers-festival.de/volunteers/")
                }
            }
            item(key = "festival-moersland") {
                InfoRow(title = stringResource(R.string.info_row_moersland)) {
                    onOpenWeb("https://www.moers-festival.de/moersland/")
                }
            }
            item(key = "festival-lodging") {
                InfoRow(title = stringResource(R.string.info_row_lodging)) {
                    onOpenWeb("https://www.moers-festival.de/infos/schlafen-zelten-campen/")
                }
            }
            item(key = "festival-accessibility") {
                InfoRow(title = stringResource(R.string.info_row_accessibility)) {
                    onOpenWeb("https://www.moers-festival.de/infos/awareness-barrierefreiheit/")
                }
            }
            item(key = "festival-moerschandise") {
                InfoRow(title = stringResource(R.string.info_row_moerschandise)) {
                    onOpenWeb("https://www.moers-festival.de/moerschandise/")
                }
            }
            item(key = "festival-sponsors") {
                InfoRow(
                    title = stringResource(R.string.info_row_sponsors),
                    showDivider = false,
                ) {
                    onOpenWeb("https://www.moers-festival.de/f%C3%B6rdern/f%C3%B6rderer-partner/")
                }
            }

            item(key = "settings-header") {
                InfoSectionHeader(title = stringResource(R.string.info_section_settings))
            }
            item(key = "settings-notifications") {
                InfoRow(
                    title = stringResource(R.string.info_row_notifications),
                    supportingText = stringResource(R.string.info_row_notifications_description),
                    leadingIcon = Icons.Rounded.NotificationsActive,
                    trailingIcon = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    showDivider = false,
                ) {
                    onOpenNotificationSettings()
                }
            }

            if (BuildConfig.DEBUG) {
                item(key = "debug-header") {
                    InfoSectionHeader(title = stringResource(R.string.info_section_debug))
                }
                item(key = "debug-fcm-token") {
                    DebugFcmTokenSection()
                }
            }

            item(key = "other-header") {
                InfoSectionHeader(title = stringResource(R.string.info_section_other))
            }
            item(key = "other-app-information") {
                InfoRow(
                    title = stringResource(com.lambdadigamma.moersfestival.R.string.about_this_app),
                    leadingIcon = Icons.Rounded.Info,
                    trailingIcon = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                ) {
                    onOpenAppInformation()
                }
            }
            item(key = "other-legal") {
                InfoRow(title = stringResource(R.string.info_row_legal)) {
                    onOpenWeb(FESTIVAL_LEGAL_URL)
                }
            }
            item(key = "other-licenses") {
                InfoRow(
                    title = stringResource(R.string.info_row_licenses),
                    leadingIcon = Icons.Rounded.Info,
                    trailingIcon = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    showDivider = false,
                ) {
                    onOpenLicenses()
                }
            }
        }
    }
}

@Composable
private fun InfoNotificationOptInBanner(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val colors = MaterialTheme.colorScheme

    Surface(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        shape = RoundedCornerShape(24.dp),
        color = colors.primaryContainer,
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Surface(
                shape = CircleShape,
                color = colors.onPrimaryContainer.copy(alpha = 0.12f),
            ) {
                Icon(
                    imageVector = Icons.Rounded.NotificationsActive,
                    contentDescription = null,
                    tint = colors.onPrimaryContainer,
                    modifier = Modifier
                        .padding(10.dp)
                        .size(22.dp),
                )
            }

            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(
                    text = stringResource(R.string.info_notification_prompt_title),
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = colors.onPrimaryContainer,
                )
                Text(
                    text = stringResource(R.string.info_notification_prompt_body),
                    style = MaterialTheme.typography.bodyMedium,
                    color = colors.onPrimaryContainer.copy(alpha = 0.78f),
                )
            }

            OutlinedButton(
                onClick = onClick,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(text = stringResource(R.string.info_notification_prompt_action))
            }
        }
    }
}

@Composable
private fun DebugFcmTokenSection() {
    val context = LocalContext.current
    val clipboardManager = remember(context) {
        context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    }
    var refreshKey by remember { mutableIntStateOf(0) }
    var isLoading by remember { mutableStateOf(true) }
    var token by remember { mutableStateOf<String?>(null) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    DisposableEffect(refreshKey) {
        var isActive = true

        isLoading = true
        token = null
        errorMessage = null

        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!isActive) {
                return@addOnCompleteListener
            }

            isLoading = false
            if (task.isSuccessful) {
                token = task.result
            } else {
                errorMessage = task.exception?.localizedMessage
                    ?: context.getString(R.string.info_debug_fcm_token_error_unknown)
            }
        }

        onDispose {
            isActive = false
        }
    }

    val statusText = when {
        isLoading -> stringResource(R.string.info_debug_fcm_token_loading)
        errorMessage != null -> stringResource(R.string.info_debug_fcm_token_error, errorMessage.orEmpty())
        token.isNullOrBlank() -> stringResource(R.string.info_debug_fcm_token_empty)
        else -> token.orEmpty()
    }

    ListItem(
        headlineContent = {
            Text(
                text = stringResource(R.string.info_debug_fcm_token_title),
                style = MaterialTheme.typography.bodyLarge,
            )
        },
        supportingContent = {
            Column(
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Text(
                    text = statusText,
                    style = MaterialTheme.typography.bodyMedium,
                    color = if (errorMessage != null) {
                        MaterialTheme.colorScheme.error
                    } else {
                        MaterialTheme.colorScheme.onSurfaceVariant
                    },
                )
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    TextButton(
                        enabled = !token.isNullOrBlank(),
                        onClick = {
                            val clip = ClipData.newPlainText(
                                context.getString(R.string.info_debug_fcm_token_clip_label),
                                token.orEmpty(),
                            )
                            clipboardManager.setPrimaryClip(clip)
                        },
                    ) {
                        Icon(
                            imageVector = Icons.Rounded.ContentCopy,
                            contentDescription = null,
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(text = stringResource(R.string.info_debug_fcm_token_copy))
                    }
                    TextButton(
                        enabled = !isLoading,
                        onClick = {
                            refreshKey += 1
                        },
                    ) {
                        Icon(
                            imageVector = Icons.Rounded.Refresh,
                            contentDescription = null,
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(text = stringResource(R.string.info_debug_fcm_token_refresh))
                    }
                }
            }
        },
        leadingContent = {
            Icon(
                imageVector = Icons.Rounded.NotificationsActive,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        },
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
    )
}

@Composable
private fun InfoIntro(
    modifier: Modifier = Modifier,
) {
    ListItem(
        modifier = modifier.fillMaxWidth(),
        leadingContent = {
            Surface(
                shape = CircleShape,
                color = MaterialTheme.colorScheme.primaryContainer,
            ) {
                Icon(
                    imageVector = Icons.Rounded.Info,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimaryContainer,
                    modifier = Modifier.padding(10.dp),
                )
            }
        },
        headlineContent = {
            Text(
                text = stringResource(R.string.info_hero_title),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
            )
        },
        supportingContent = {
            Text(text = stringResource(R.string.info_hero_description))
        },
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
    )
}

@Composable
private fun InfoSectionHeader(title: String) {
    Text(
        text = title.uppercase(),
        style = MaterialTheme.typography.labelMedium,
        color = MaterialTheme.colorScheme.primary,
        modifier = Modifier.padding(start = 24.dp, end = 24.dp, top = 24.dp, bottom = 8.dp),
    )
}

@Composable
fun InfoRow(
    title: String,
    supportingText: String? = null,
    leadingIcon: ImageVector = Icons.Rounded.Link,
    trailingIcon: ImageVector = Icons.AutoMirrored.Rounded.OpenInNew,
    showDivider: Boolean = true,
    onClick: () -> Unit,
) {
    ListItem(
        headlineContent = {
            Text(
                text = title,
                style = MaterialTheme.typography.bodyLarge,
            )
        },
        supportingContent = supportingText?.let { text ->
            {
                Text(text = text)
            }
        },
        leadingContent = {
            Icon(
                imageVector = leadingIcon,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        },
        trailingContent = {
            Icon(
                imageVector = trailingIcon,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        },
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
    )
    if (showDivider) {
        InfoDivider()
    }
}

@Composable
private fun InfoDivider() {
    HorizontalDivider(
        modifier = Modifier.padding(start = 72.dp, end = 24.dp),
        thickness = Dp.Hairline,
        color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.38f),
    )
}
