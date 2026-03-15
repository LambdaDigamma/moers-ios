package com.lambdadigamma.news.presentation.list

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Scaffold
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.news.presentation.PostType

@Composable
fun NewsScreen(
    uiState: NewsListUiState,
    onIntent: (NewsListIntent) -> Unit,
) {

    Scaffold(topBar = {
        TopBar(title = "News")
    }) { paddingValues ->

        PullToRefreshBox(
            isRefreshing = uiState.isLoading,
            onRefresh = { onIntent(NewsListIntent.RefreshNews) },
            modifier = Modifier
                .padding(top = paddingValues.calculateTopPadding())
                .fillMaxSize()
        ) {

            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {

                items(uiState.data.items) { newsItem ->

                    val onClick = {
                        if (newsItem.type == PostType.INSTAGRAM && !newsItem.externalHref.isNullOrBlank()) {
                            onIntent(NewsListIntent.OpenExternalPost(newsItem.externalHref))
                        } else {
                            onIntent(NewsListIntent.ShowPost(newsItem.id))
                        }
                    }

                    if (newsItem.type == PostType.INSTAGRAM) {
                        InstagramPostCard(newsItem, onClick = onClick)
                    } else {
                        DefaultPostCard(newsItem, onClick = onClick)
                    }

                }

            }

        }

    }

}