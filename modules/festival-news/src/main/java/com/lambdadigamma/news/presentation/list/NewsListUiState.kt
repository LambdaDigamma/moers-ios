package com.lambdadigamma.news.presentation.list

import android.os.Parcelable
import androidx.compose.runtime.Immutable
import com.lambdadigamma.events.presentation.EventDisplayable
import com.lambdadigamma.news.presentation.PostDisplayable
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class NewsItem(val id: Int): Parcelable

@Parcelize
data class NewsListData(
    val items: List<PostDisplayable> = emptyList()
): Parcelable

@Immutable
@Parcelize
data class NewsListUiState(
    val isLoading: Boolean = false,
    val data: NewsListData = NewsListData(),
    val isError: Throwable? = null,
) : Parcelable {

    sealed class PartialState {
        data object Loading : PartialState()

        data class Fetched(
            val data: NewsListData
        ) : PartialState()

        data class Error(val throwable: Throwable) : PartialState()
    }
}
