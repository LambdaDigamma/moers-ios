package com.lambdadigamma.news.presentation.list

import com.lambdadigamma.events.presentation.timetable.TimetableIntent
import com.lambdadigamma.news.presentation.PostDisplayable

sealed class NewsListIntent {
    data object GetNews : NewsListIntent()

    data object RefreshNews : NewsListIntent()

    data class ShowPost(val id: Int) : NewsListIntent()

}
