package com.lambdadigamma.news.presentation.list

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.news.presentation.PostType

@Composable
fun NewsScreen(
    uiState: NewsListUiState,
    onIntent: (NewsListIntent) -> Unit,
) {

    LaunchedEffect(key1 = "reloadPosts") {
        onIntent(NewsListIntent.RefreshNews)
    }

    Scaffold(topBar = {
        TopBar(title = "News")
    }) {

        Box(modifier = Modifier.padding(top = it.calculateTopPadding())) {

            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                
                items(uiState.data.items) { newsItem ->

                    if (newsItem.type == PostType.INSTAGRAM) {
                        InstagramPostCard(newsItem, onClick = {
                            onIntent(NewsListIntent.ShowPost(newsItem.id))
                        })
                    } else {
                        DefaultPostCard(newsItem, onClick = {
                            onIntent(NewsListIntent.ShowPost(newsItem.id))
                        })
                    }

                }
                
            } 

        }

    }

}