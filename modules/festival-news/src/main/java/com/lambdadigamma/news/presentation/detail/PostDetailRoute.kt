package com.lambdadigamma.news.presentation.detail

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle

@Composable
fun PostDetailRoute(
    viewModel: PostDetailViewModel = hiltViewModel(),
    onBack: () -> Unit
) {

    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    LaunchedEffect("load") {
        viewModel.acceptIntent(PostDetailIntent.GetData)
    }

    PostDetailScreen(
        uiState = uiState,
        onBack = onBack,
        onIntent = viewModel::acceptIntent
    )

}