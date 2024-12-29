package app.moers.news.data

import androidx.lifecycle.LiveData
import app.moers.news.data.NewsDao
import app.moers.core.AppExecutors
import app.moers.core.NetworkBoundResource
import app.moers.core.Resource

class NewsRepository(
    private val newsDao: NewsDao,
    private val newsService: NewsService,
    private val appExecutors: AppExecutors = AppExecutors()
) {

    fun getNews(): LiveData<Resource<List<RssItem>?>> {
        return object : NetworkBoundResource<List<RssItem>, List<RssItem>>(appExecutors) {

            override fun saveCallResult(item: List<RssItem>) {
                newsDao.insertNews(item)
            }

            override fun shouldFetch(data: List<RssItem>?): Boolean =
                true //data == null || data.isEmpty()

            override fun loadFromDb() = newsDao.getNews()

            override fun createCall() = newsService.getRPFeed()

        }.asLiveData()
    }

}