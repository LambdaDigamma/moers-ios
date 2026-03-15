package com.lambdadigamma.news.presentation.detail

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.calculateEndPadding
import androidx.compose.foundation.layout.calculateStartPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.news.data.remote.model.PageId
import com.lambdadigamma.news.presentation.PostDisplayable
import com.lambdadigamma.pages.presentation.PageBlockRenderer
import com.lambdadigamma.pages.presentation.PageView

@Composable
fun PostDetailScreen(
    uiState: PostDetailUiState,
    onIntent: (PostDetailIntent) -> Unit,
    onBack: () -> Unit = {},
) {

    LaunchedEffect("load") {

    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(text = "Details")
                },
                navigationIcon = {
                    NavigationBackButton(onBack = onBack)
                }
            )
        }
    ) { padding ->

        uiState.isLoading.let {
            if (it) {
                Column(modifier = Modifier.padding(padding)) {
                    Text("Loading")
                }
            }
        }

        uiState.isError.let {
            if (it != null) {
                Column(modifier = Modifier.padding(padding)) {
                    Text("Error")
                }
            }
        }

        uiState.post?.let { post ->

            val externalHref = if (post.externalHref.isNullOrEmpty()) {
                null
            } else {
                post.externalHref
            }

            if (externalHref != null) {
                PostDetailWebView(
                    modifier = Modifier.padding(
                        top = padding.calculateTopPadding(),
                        start = padding.calculateStartPadding(LayoutDirection.Ltr),
                        end = padding.calculateEndPadding(LayoutDirection.Ltr),
                    ),
                    url = externalHref
                )
            } else {
                NativePostPage(
                    modifier = Modifier.padding(padding),
                    post = post
                )
            }

        }

    }

}

@Composable
private fun NativePostPage(
    modifier: Modifier = Modifier,
    post: PostDisplayable,
) {
    val scrollState = rememberScrollState()

    Column(modifier = modifier.verticalScroll(scrollState)) {
        PageBlockRenderer(blocks = post.blocks)
    }


//    PageView(
//        pageId = pageId
//    )


//    PageBlockRenderer(
//        blocks = event.blocks,
//        modifier = Modifier.padding(top = 16.dp, bottom = 16.dp)
//    )

}