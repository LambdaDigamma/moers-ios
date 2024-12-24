package com.lambdadigamma.newsfeature.ui

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import app.moers.news.data.NewsDao
import com.lambdadigamma.newsfeature.data.NewsRepository
import com.lambdadigamma.newsfeature.data.NewsService
import com.lambdadigamma.newsfeature.data.RssItem
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class RssItemDetailViewModel @Inject constructor(
    private val newsDao: NewsDao
) : ViewModel() {

    lateinit var item: LiveData<RssItem>

    private var newsRepository: NewsRepository = NewsRepository(
        newsDao,
        NewsService.getRPService()
    )

    fun configure(id: Long) {
        item = newsDao.getRssItem(id)
    }

}
