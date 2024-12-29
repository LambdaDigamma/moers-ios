package com.lambdadigamma.radio.overview

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.core.ui.ResourcefulContent
import com.lambdadigamma.radio.R

@Composable
fun BroadcastOverviewScreen(onOpenRadioBroadcast: (Int) -> Unit, onBack: () -> Unit) {

    val viewModel: RadioBroadcastOverviewViewModel = hiltViewModel()

    ResourcefulContent(resource = viewModel.load(), onLoad = { /*TODO*/ }) { broadcasts ->
        BroadcastOverviewContent(
            radioBroadcasts = broadcasts,
            onOpenRadioBroadcast = onOpenRadioBroadcast,
            onBack = onBack
        )
    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BroadcastOverviewContent(
    radioBroadcasts: List<RadioBroadcastListUiState>,
    onOpenRadioBroadcast: (Int) -> Unit,
    onBack: () -> Unit
) {

    val context = LocalContext.current

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(text = stringResource(R.string.community_radio_title))
                },
                navigationIcon = {
                    NavigationBackButton(onBack = onBack)
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .fillMaxSize()
        ) {

            Column(modifier = Modifier.padding(16.dp)) {

                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {

                    Text(
                        text = stringResource(R.string.community_radio_description),
                        style = MaterialTheme.typography.bodyMedium
                    )

                    OutlinedButton(
                        modifier = Modifier.fillMaxWidth(),
                        onClick = {
                            val url = Uri.parse("http://www.buergerfunk-moers.de")
                            val browserIntent = Intent(Intent.ACTION_VIEW, url)
                            ContextCompat.startActivity(context, browserIntent, null)
                        }
                    ) {
                        Text(text = stringResource(R.string.learn_more_action))
                    }

                }

                Text(
                    text = stringResource(R.string.next_shows_headline),
                    style = MaterialTheme.typography.headlineSmall,
                    modifier = Modifier
                        .padding(top = 20.dp)
                        .padding(bottom = 0.dp)
                )
            }

            Column(
                verticalArrangement = Arrangement.spacedBy(0.dp),
                modifier = Modifier.padding(bottom = 32.dp)
            ) {
                for (broadcast in radioBroadcasts) {
                    Column {
                        RadioBroadcastRow(
                            modifier = Modifier
                                .clickable { onOpenRadioBroadcast(broadcast.id) }
                                .padding(horizontal = 16.dp, vertical = 6.dp),
                            radioBroadcast = broadcast
                        )
                    }
                }
            }

        }
    }

}

@Preview
@Composable
private fun PreviewBroadcastOverviewScreen() {
    MeinMoersTheme {
        BroadcastOverviewScreen(onOpenRadioBroadcast = {}, onBack = {})
    }
}