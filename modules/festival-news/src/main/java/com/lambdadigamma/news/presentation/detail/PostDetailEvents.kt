package com.lambdadigamma.news.presentation.detail

sealed class PostDetailEvents {
    data class ShowEvent(val id: Int) : PostDetailEvents()

}
