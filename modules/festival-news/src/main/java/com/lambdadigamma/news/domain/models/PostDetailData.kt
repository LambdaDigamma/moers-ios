package com.lambdadigamma.news.domain.models

import com.lambdadigamma.events.data.remote.model.Event
import com.lambdadigamma.news.data.remote.model.Post
import com.lambdadigamma.pages.data.remote.model.Page

data class PostDetailData(
    val post: Post,
    val page: Page?,
) {



}