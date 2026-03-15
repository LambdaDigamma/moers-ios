package com.lambdadigamma.news.presentation.detail

import android.annotation.SuppressLint
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.kevinnzou.web.LoadingState
import com.kevinnzou.web.WebView
import com.kevinnzou.web.rememberWebViewNavigator
import com.kevinnzou.web.rememberWebViewState

@SuppressLint("SetJavaScriptEnabled")
@Composable
fun PostDetailWebView(
    modifier: Modifier = Modifier,
    url: String
) {

    val state = rememberWebViewState(url)
    val navigator = rememberWebViewNavigator()

    Column(modifier = modifier.fillMaxSize()) {

        val loadingState = state.loadingState
        if (loadingState is LoadingState.Loading) {
            LinearProgressIndicator(
                progress = { loadingState.progress },
                modifier = Modifier.fillMaxWidth()
            )
        }

        WebView(
            modifier = Modifier.fillMaxSize(),
            state = state,
            navigator = navigator,
            onCreated = { it.settings.javaScriptEnabled = true }
        )

    }

}