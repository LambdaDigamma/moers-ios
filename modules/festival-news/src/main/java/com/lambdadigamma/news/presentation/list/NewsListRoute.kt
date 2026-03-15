package com.lambdadigamma.news.presentation.list

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.extensions.collectWithLifecycle

@Composable
fun NewsListRoute(
    viewModel: NewsViewModel = hiltViewModel(),
    onShowPost: (Int) -> Unit,
    onShowUrl: (String) -> Unit,
) {

    LaunchedEffect(key1 = "reloadPosts", block = {
        viewModel.acceptIntent(NewsListIntent.RefreshNews)
    })

    val uiState by viewModel.uiState
        .collectAsStateWithLifecycle()

    NewsScreen(
        uiState = uiState,
        onIntent = viewModel::acceptIntent,
    )

    viewModel.event.collectWithLifecycle {
        when (it) {
            is NewsListEvents.ShowNews -> {
                onShowPost(it.id)
            }
            is NewsListEvents.OpenExternalLink -> {
                onShowUrl(it.url)
            }
        }
    }


}
