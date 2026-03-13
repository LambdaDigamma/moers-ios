package com.lambdadigamma.moers.explore

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.moers.R

enum class ExploreNavigationAction {
    RadioBroadcasts
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExploreScreen(onNavigate: (ExploreNavigationAction) -> Unit) {

    Scaffold(topBar = {
        TopBar(title = stringResource(id = R.string.navigation_explore))
    }) { paddingValues ->
        Column(
            modifier = Modifier
                .padding(paddingValues)
                .padding(16.dp)
                .fillMaxSize()
        ) {

            ElevatedCard(
                onClick = {
                    onNavigate(ExploreNavigationAction.RadioBroadcasts)
                },
                elevation = CardDefaults.elevatedCardElevation(8.dp)
            ) {
                Box(
                    modifier = Modifier
                        .aspectRatio(16f / 9f)
                        .clip(RoundedCornerShape(12.dp))
                        .background(MaterialTheme.colorScheme.surfaceVariant),
                    contentAlignment = Alignment.BottomStart,
                ) {
                    AsyncImage(
                        model = "https://images.unsplash.com/photo-1598743400863-0201c7e1445b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=600&q=80",
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        alignment = Alignment.TopCenter,
                        modifier = Modifier
                            .fillMaxWidth()
                    )
                    Text(
                        text = "Bürgerfunk",
                        style = MaterialTheme.typography.headlineSmall,
                        modifier = Modifier.padding(horizontal = 20.dp, vertical = 20.dp),
                        color = Color.White
                    )
                }
            }

//            Button(modifier = Modifier.fillMaxWidth(), onClick = {
//                onNavigate(ExploreNavigationAction.RadioBroadcasts)
//            }) {
//                Text(text = "Bürgerfunk")
//            }

        }
    }

}

@Preview
@Composable
fun ExploreScreenPreview() {
    MeinMoersTheme {
        ExploreScreen(onNavigate = {

        })
    }
}