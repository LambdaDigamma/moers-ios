package com.lambdadigamma.news.presentation.list

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.refresh.RefreshFailureMessageFormatter
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.news.R
import com.lambdadigamma.news.presentation.PostDisplayable
import com.lambdadigamma.news.presentation.PostType

@Composable
fun NewsScreen(
    uiState: NewsListUiState,
    onIntent: (NewsListIntent) -> Unit,
    snackbarHostState: SnackbarHostState,
) {
    Scaffold(
        topBar = {
            TopBar(title = stringResource(R.string.news_list_title))
        },
        snackbarHost = {
            SnackbarHost(hostState = snackbarHostState)
        },
    ) { paddingValues ->

        PullToRefreshBox(
            isRefreshing = uiState.isRefreshing,
            onRefresh = { onIntent(NewsListIntent.RefreshNews) },
            modifier = Modifier
                .padding(top = paddingValues.calculateTopPadding())
                .fillMaxSize()
        ) {
            when {
                uiState.data.items.isNotEmpty() -> {
                    NewsList(
                        items = uiState.data.items,
                        onIntent = onIntent,
                        bottomPadding = paddingValues.calculateBottomPadding(),
                    )
                }
                uiState.isLoading || uiState.isRefreshing -> {
                    NewsLoadingState()
                }
                uiState.isError != null -> {
                    NewsErrorState(
                        throwable = uiState.isError,
                        onRetry = { onIntent(NewsListIntent.RefreshNews) },
                    )
                }
                else -> {
                    NewsEmptyState(
                        onRetry = { onIntent(NewsListIntent.RefreshNews) },
                    )
                }
            }
        }
    }
}

@Composable
private fun NewsList(
    items: List<PostDisplayable>,
    onIntent: (NewsListIntent) -> Unit,
    bottomPadding: Dp,
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 16.dp,
            top = 16.dp,
            end = 16.dp,
            bottom = bottomPadding + 16.dp,
        ),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        items(items) { newsItem ->
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

@Composable
private fun NewsLoadingState() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        CircularProgressIndicator()
    }
}

@Composable
private fun NewsErrorState(
    throwable: Throwable,
    onRetry: () -> Unit,
) {
    val context = LocalContext.current

    NewsMessageState(
        title = stringResource(R.string.news_load_error),
        message = RefreshFailureMessageFormatter.format(
            context = context,
            throwable = throwable,
        ),
        onRetry = onRetry,
    )
}

@Composable
private fun NewsEmptyState(
    onRetry: () -> Unit,
) {
    NewsMessageState(
        title = stringResource(R.string.news_empty),
        message = stringResource(R.string.news_empty_hint),
        onRetry = onRetry,
    )
}

@Composable
private fun NewsMessageState(
    title: String,
    message: String,
    onRetry: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            textAlign = TextAlign.Center,
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = message,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = onRetry) {
            Text(text = stringResource(R.string.news_retry))
        }
    }
}
