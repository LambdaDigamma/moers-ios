package com.lambdadigamma.newsfeature.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.newsfeature.data.NewsArticle
import com.lambdadigamma.newsfeature.data.NewsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class NewsUiState(
    val articles: List<NewsArticle> = emptyList(),
    val isLoading: Boolean = true,
    val isRefreshing: Boolean = false,
    val refreshFailed: Boolean = false,
)

private data class RefreshState(
    val isRefreshing: Boolean = false,
    val hasCompleted: Boolean = false,
    val failed: Boolean = false,
)

@HiltViewModel
class NewsViewModel @Inject constructor(
    private val newsRepository: NewsRepository,
) : ViewModel() {

    private val refreshState = MutableStateFlow(RefreshState())

    val uiState: StateFlow<NewsUiState> = combine(
        newsRepository.articles,
        refreshState,
    ) { articles, refresh ->
        NewsUiState(
            articles = articles,
            isLoading = articles.isEmpty() && !refresh.hasCompleted,
            isRefreshing = refresh.isRefreshing,
            refreshFailed = refresh.failed,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), NewsUiState())

    init {
        refresh()
    }

    fun refresh() {
        if (refreshState.value.isRefreshing) return
        viewModelScope.launch {
            refreshState.update { it.copy(isRefreshing = true) }
            val result = newsRepository.refresh()
            refreshState.value = RefreshState(hasCompleted = true, failed = result.isFailure)
        }
    }
}
