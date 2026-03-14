package com.lambdadigamma.moersfestival

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Divider
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
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

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.navigation_info),
                        style = MaterialTheme.typography.headlineSmall
                    )
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .padding(paddingValues)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
        ) {
            InfoSection(title = stringResource(R.string.info_section_festival)) {
                InfoRow(title = stringResource(com.lambdadigamma.events.R.string.download_timetable)) {
                    navigationManager.navigate(object : NavigationCommand {
                        override val destination: String = NavigationDestination.EventDownload.route
                    })
                }
                InfoRow(title = stringResource(R.string.info_row_tickets)) {
                    navigateUrl("https://www.moers-festival.de/tickets/")
                }
                InfoRow(title = stringResource(R.string.info_row_festivaldorf)) {
                    navigateUrl("https://www.moers-festival.de/infos/festivaldorf/")
                }
                InfoRow(title = stringResource(R.string.info_row_volunteers)) {
                    navigateUrl("https://www.moers-festival.de/volunteers/")
                }
                InfoRow(title = stringResource(R.string.info_row_moersland)) {
                    navigateUrl("https://www.moers-festival.de/moersland/")
                }
                InfoRow(title = stringResource(R.string.info_row_lodging)) {
                    navigateUrl("https://www.moers-festival.de/infos/schlafen/")
                }
                InfoRow(title = stringResource(R.string.info_row_accessibility)) {
                    navigateUrl("https://www.moers-festival.de/infos/awareness-barrierefreiheit/")
                }
                InfoRow(title = stringResource(R.string.info_row_moerschandise)) {
                    navigateUrl("https://www.moers-festival.de/moerschandise/")
                }
                InfoRow(title = stringResource(R.string.info_row_sponsors)) {
                    navigateUrl("https://www.moers-festival.de/f%C3%B6rdern/f%C3%B6rderer-partner/")
                }
            }

            InfoSection(title = stringResource(R.string.info_section_other)) {
                InfoRow(title = stringResource(com.lambdadigamma.moersfestival.R.string.about_this_app)) {
                    navigationManager.navigate(object : NavigationCommand {
                        override val destination: String = NavigationDestination.AppInformation.route
                    })
                }
                InfoRow(title = stringResource(R.string.info_row_legal)) {
                    navigateUrl("https://moers.app/impressum")
                }
            }
        }
    }
}

@Composable
fun InfoSection(
    title: String,
    content: @Composable () -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        Text(
            text = title.uppercase(),
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
        )
        content()
        Divider(modifier = Modifier.padding(vertical = 8.dp))
    }
}

@Composable
fun InfoRow(
    title: String,
    onClick: () -> Unit
) {
    ListItem(
        headlineContent = { Text(text = title) },
        modifier = Modifier.clickable { onClick() }
    )
}
