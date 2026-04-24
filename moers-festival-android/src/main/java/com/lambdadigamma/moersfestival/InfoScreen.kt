package com.lambdadigamma.moersfestival

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.rounded.OpenInNew
import androidx.compose.material.icons.rounded.DownloadForOffline
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.Link
import androidx.compose.material.icons.rounded.NotificationsActive
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MediumTopAppBar
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberTopAppBarState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.navigation.NavigationCommand
import com.lambdadigamma.core.navigation.NavigationDestination
import com.lambdadigamma.core.navigation.NavigationManager
import java.net.URLEncoder
import java.nio.charset.StandardCharsets

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun InfoScreen(navigationManager: NavigationManager) {
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
) {
    val scrollBehavior = TopAppBarDefaults.enterAlwaysScrollBehavior(rememberTopAppBarState())

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            MediumTopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.navigation_info),
                        maxLines = 1,
                    )
                },
                scrollBehavior = scrollBehavior,
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
            item {
                InfoIntro()
            }

            item {
                InfoSectionHeader(title = stringResource(R.string.info_section_festival))
            }
            item {
                InfoRow(
                    title = stringResource(com.lambdadigamma.events.R.string.download_timetable),
                    leadingIcon = Icons.Rounded.DownloadForOffline,
                    trailingIcon = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                ) {
                    onOpenDownload()
                }
            }
            item {
                InfoRow(title = stringResource(R.string.info_row_tickets)) {
                    onOpenWeb("https://www.moers-festival.de/tickets/")
                }
            }
            item {
                InfoRow(title = stringResource(R.string.info_row_festivaldorf)) {
                    onOpenWeb("https://www.moers-festival.de/infos/festivaldorf/")
                }
            }
            item {
                InfoRow(title = stringResource(R.string.info_row_volunteers)) {
                    onOpenWeb("https://www.moers-festival.de/volunteers/")
                }
            }
            item {
                InfoRow(title = stringResource(R.string.info_row_moersland)) {
                    onOpenWeb("https://www.moers-festival.de/moersland/")
                }
            }
            item {
                InfoRow(title = stringResource(R.string.info_row_lodging)) {
                    onOpenWeb("https://www.moers-festival.de/infos/schlafen/")
                }
            }
            item {
                InfoRow(title = stringResource(R.string.info_row_accessibility)) {
                    onOpenWeb("https://www.moers-festival.de/infos/awareness-barrierefreiheit/")
                }
            }
            item {
                InfoRow(title = stringResource(R.string.info_row_moerschandise)) {
                    onOpenWeb("https://www.moers-festival.de/moerschandise/")
                }
            }
            item {
                InfoRow(
                    title = stringResource(R.string.info_row_sponsors),
                    showDivider = false,
                ) {
                    onOpenWeb("https://www.moers-festival.de/f%C3%B6rdern/f%C3%B6rderer-partner/")
                }
            }

            item {
                InfoSectionHeader(title = stringResource(R.string.info_section_settings))
            }
            item {
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

            item {
                InfoSectionHeader(title = stringResource(R.string.info_section_other))
            }
            item {
                InfoRow(
                    title = stringResource(com.lambdadigamma.moersfestival.R.string.about_this_app),
                    leadingIcon = Icons.Rounded.Info,
                    trailingIcon = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                ) {
                    onOpenAppInformation()
                }
            }
            item {
                InfoRow(title = stringResource(R.string.info_row_legal)) {
                    onOpenWeb(FESTIVAL_LEGAL_URL)
                }
            }
            item {
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
