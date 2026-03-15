package com.lambdadigamma.news.presentation.detail

sealed class PostDetailIntent {
    data object GetData : PostDetailIntent()

    data object RefreshPost : PostDetailIntent()

    data object RefreshPage : PostDetailIntent()

    data object GoBack : PostDetailIntent()
}
