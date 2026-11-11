package com.lambdadigamma.moers.explore

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.LargeTopBar
import com.lambdadigamma.moers.R

enum class ExploreNavigationAction {
    RadioBroadcasts
}

private const val RADIO_IMAGE_URL =
    "https://images.unsplash.com/photo-1598743400863-0201c7e1445b?auto=format&fit=crop&w=1200&q=80"

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExploreScreen(onNavigate: (ExploreNavigationAction) -> Unit) {
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            LargeTopBar(
                title = stringResource(id = R.string.navigation_explore),
                scrollBehavior = scrollBehavior,
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp)
        ) {
            ElevatedCard(
                onClick = { onNavigate(ExploreNavigationAction.RadioBroadcasts) },
                modifier = Modifier.fillMaxWidth(),
            ) {
                Box(
                    modifier = Modifier
                        .aspectRatio(16f / 9f)
                        .background(MaterialTheme.colorScheme.surfaceVariant),
                    contentAlignment = Alignment.BottomStart,
                ) {
                    AsyncImage(
                        model = RADIO_IMAGE_URL,
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(
                                Brush.verticalGradient(
                                    0.5f to Color.Transparent,
                                    1f to Color.Black.copy(alpha = 0.6f),
                                )
                            )
                    )
                    Text(
                        text = stringResource(R.string.explore_radio_title),
                        style = MaterialTheme.typography.headlineSmall,
                        modifier = Modifier.padding(20.dp),
                        color = Color.White
                    )
                }
            }
        }
    }
}

@Preview
@Composable
private fun ExploreScreenPreview() {
    MeinMoersTheme {
        ExploreScreen(onNavigate = {})
    }
}
