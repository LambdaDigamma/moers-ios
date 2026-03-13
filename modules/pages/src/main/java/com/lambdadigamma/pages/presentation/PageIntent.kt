package com.lambdadigamma.pages.presentation

sealed class PageIntent {

    data object GetData : PageIntent()

    data object RefreshPage : PageIntent()

}
