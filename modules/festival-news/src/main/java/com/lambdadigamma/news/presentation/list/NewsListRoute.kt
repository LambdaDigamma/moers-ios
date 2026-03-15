package com.lambdadigamma.news.presentation.list

import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.platform.LocalContext
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.extensions.collectWithLifecycle

@Composable
fun NewsListRoute(
    viewModel: NewsViewModel = hiltViewModel(),
    onShowPost: (Int) -> Unit,
) {

    val context = LocalContext.current

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
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(it.url))
                context.startActivity(intent)
            }
        }
    }


}