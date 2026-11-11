package com.lambdadigamma.newsfeature.ui

import android.text.format.DateUtils
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil3.compose.AsyncImage
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.ErrorContent
import com.lambdadigamma.core.ui.LargeTopBar
import com.lambdadigamma.core.ui.LoadingContent
import com.lambdadigamma.core.ui.rememberOpenUrl
import com.lambdadigamma.news.R
import com.lambdadigamma.newsfeature.data.NewsArticle

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewsScreen() {
    val viewModel: NewsViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val openUrl = rememberOpenUrl()
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()
    val snackbarHostState = remember { SnackbarHostState() }
    val refreshFailedMessage = stringResource(R.string.news_refresh_failed)

    LaunchedEffect(uiState.refreshFailed, uiState.articles.isEmpty()) {
        if (uiState.refreshFailed && uiState.articles.isNotEmpty()) {
            snackbarHostState.showSnackbar(refreshFailedMessage)
        }
    }

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            LargeTopBar(
                title = stringResource(id = R.string.navigation_news),
                scrollBehavior = scrollBehavior,
            )
        },
        snackbarHost = { SnackbarHost(snackbarHostState) },
    ) { padding ->
        PullToRefreshBox(
            isRefreshing = uiState.isRefreshing && !uiState.isLoading,
            onRefresh = viewModel::refresh,
            modifier = Modifier
                .padding(padding)
                .fillMaxSize(),
        ) {
            when {
                uiState.isLoading -> LoadingContent()
                uiState.articles.isEmpty() -> ErrorContent(
                    message = stringResource(R.string.news_list_error_description),
                    onRetry = viewModel::refresh,
                )
                else -> NewsList(articles = uiState.articles, onOpenArticle = { openUrl(it.link) })
            }
        }
    }
}

@Composable
private fun NewsList(articles: List<NewsArticle>, onOpenArticle: (NewsArticle) -> Unit) {
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = 340.dp),
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 16.dp),
    ) {
        itemsIndexed(
            items = articles,
            key = { _, article -> article.id },
            span = { index, _ -> if (index == 0) GridItemSpan(maxLineSpan) else GridItemSpan(1) },
        ) { index, article ->
            if (index == 0) {
                HeadlineArticle(article = article, onClick = { onOpenArticle(article) })
            } else {
                ArticleRow(article = article, onClick = { onOpenArticle(article) })
            }
        }
    }
}

@Composable
private fun HeadlineArticle(article: NewsArticle, onClick: () -> Unit) {
    ElevatedCard(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
    ) {
        article.imageUrl?.let { imageUrl ->
            AsyncImage(
                model = imageUrl,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(16f / 9f)
                    .background(MaterialTheme.colorScheme.surfaceVariant),
            )
        }
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(
                text = article.title,
                style = MaterialTheme.typography.titleLarge,
            )
            article.summary?.let { summary ->
                Text(
                    text = summary,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis,
                )
            }
            Text(
                text = article.metadata(),
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun ArticleRow(article: NewsArticle, onClick: () -> Unit) {
    ListItem(
        headlineContent = {
            Text(text = article.title, maxLines = 3, overflow = TextOverflow.Ellipsis)
        },
        supportingContent = { Text(article.metadata()) },
        trailingContent = article.imageUrl?.let { imageUrl ->
            {
                AsyncImage(
                    model = imageUrl,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .size(88.dp)
                        .clip(MaterialTheme.shapes.medium)
                        .background(MaterialTheme.colorScheme.surfaceVariant),
                )
            }
        },
        modifier = Modifier.clickable(onClick = onClick),
    )
}

/** For example "RP Online · 2 hours ago". */
@Composable
private fun NewsArticle.metadata(): String {
    val relativeTime = publishedAt?.let {
        DateUtils.getRelativeTimeSpanString(
            it,
            System.currentTimeMillis(),
            DateUtils.MINUTE_IN_MILLIS,
            DateUtils.FORMAT_ABBREV_RELATIVE,
        ).toString()
    }
    return listOfNotNull(source, relativeTime).joinToString(" · ")
}

@Preview(showBackground = true, heightDp = 800)
@Composable
private fun NewsListPreview() {
    val now = System.currentTimeMillis()
    MeinMoersTheme {
        NewsList(
            articles = listOf(
                NewsArticle(
                    id = "1",
                    title = "Lesung in Moers: Stilles Gedenken statt Beifall",
                    link = "https://rp-online.de",
                    summary = "Zum Gedenken an die Pogromnacht lasen Schülerinnen und Schüler im Alten Landratsamt.",
                    imageUrl = null,
                    publishedAt = now - 2 * 60 * 60 * 1000,
                    source = "RP Online",
                ),
                NewsArticle(
                    id = "2",
                    title = "Wunschbäume für Kinder und Senioren – „Zeigen, wie schön Zusammenhalt sein kann“",
                    link = "https://rp-online.de",
                    summary = null,
                    imageUrl = null,
                    publishedAt = now - 5 * 60 * 60 * 1000,
                    source = "RP Online",
                ),
            ),
            onOpenArticle = {},
        )
    }
}
