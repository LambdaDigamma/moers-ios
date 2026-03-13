package com.lambdadigamma.news.presentation.di

import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.events.presentation.timetable.EventsUiState
import com.lambdadigamma.news.presentation.NewsNavigationFactory
import com.lambdadigamma.news.presentation.detail.PostDetailEvents
import com.lambdadigamma.news.presentation.detail.PostDetailUiState
import com.lambdadigamma.news.presentation.list.NewsListUiState
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ViewModelComponent
import dagger.hilt.components.SingletonComponent
import dagger.multibindings.IntoSet
import javax.inject.Singleton

@Module
@InstallIn(ViewModelComponent::class)
internal object NewsViewModelModule {

    @Provides
    fun provideInitialNewsListUiState(): NewsListUiState = NewsListUiState(isLoading = true)

    @Provides
    fun provideInitialPostDetailUiState(): PostDetailUiState = PostDetailUiState(isLoading = true)

}

@Module
@InstallIn(SingletonComponent::class)
internal interface NewsSingletonModule {

    @Singleton
    @Binds
    @IntoSet
    fun bindNewsNavigationFactory(factory: NewsNavigationFactory): NavigationFactory
}
