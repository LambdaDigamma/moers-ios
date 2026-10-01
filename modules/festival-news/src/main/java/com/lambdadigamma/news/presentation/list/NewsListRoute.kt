package com.lambdadigamma.news.presentation.list

import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.extensions.collectWithLifecycle
import com.lambdadigamma.core.refresh.RefreshFailureMessageFormatter
import com.lambdadigamma.news.R

@Composable
fun NewsListRoute(
    viewModel: NewsViewModel = hiltViewModel(),
    onShowPost: (Int) -> Unit,
    onShowUrl: (String) -> Unit,
) {

    val context = LocalContext.current
    val snackbarHostState = remember { SnackbarHostState() }
    val retryActionLabel = stringResource(R.string.news_retry)

    LaunchedEffect(key1 = "reloadPosts", block = {
        viewModel.acceptIntent(NewsListIntent.RefreshNews)
    })

    val uiState by viewModel.uiState
        .collectAsStateWithLifecycle()

    NewsScreen(
        uiState = uiState,
        onIntent = viewModel::acceptIntent,
        snackbarHostState = snackbarHostState,
    )

    viewModel.event.collectWithLifecycle {
        when (it) {
            is NewsListEvents.ShowNews -> {
                onShowPost(it.id)
            }
            is NewsListEvents.OpenExternalLink -> {
                onShowUrl(it.url)
            }
            is NewsListEvents.ShowRefreshError -> {
                val result = snackbarHostState.showSnackbar(
                    message = RefreshFailureMessageFormatter.format(
                        context = context,
                        throwable = it.throwable,
                        lastSuccessfulRefresh = it.lastSuccessfulRefresh,
                    ),
                    actionLabel = retryActionLabel,
                )
                if (result == SnackbarResult.ActionPerformed) {
                    viewModel.acceptIntent(NewsListIntent.RefreshNews)
                }
            }
        }
    }


}
