package com.lambdadigamma.radio.detail

import androidx.compose.runtime.Composable
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.ui.ResourcefulContent

@Composable
fun BroadcastDetailScreen(id: Int, onBack: () -> Unit) {

    val viewModel: RadioBroadcastDetailViewModel = hiltViewModel()
    viewModel.radioBroadcastId = id

    ResourcefulContent(resource = viewModel.load(), onLoad = { /*TODO*/ }) { broadcast ->
        BroadcastDetailContent(broadcast = broadcast, onBack = onBack)
    }

}