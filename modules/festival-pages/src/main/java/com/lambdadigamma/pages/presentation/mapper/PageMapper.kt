package com.lambdadigamma.pages.presentation.mapper

import com.lambdadigamma.pages.data.local.model.PageCached
import com.lambdadigamma.pages.data.remote.model.Page
import com.lambdadigamma.pages.presentation.PageDisplayable

fun PageCached.toPresentationModel() = PageDisplayable(
    id = id,
    title = title ?: "",
)

fun Page.toPresentationModel() = PageDisplayable(
    id = id,
    title = title ?: "",
)