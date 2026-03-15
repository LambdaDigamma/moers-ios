package com.lambdadigamma.events.presentation.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dagger.multibindings.IntoSet
import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.events.presentation.EventsNavigationFactory
import com.lambdadigamma.events.presentation.detail.EventDetailUiState
import com.lambdadigamma.events.presentation.download.DownloadEventsUiState
import com.lambdadigamma.events.presentation.favorites.FavoriteEventsUiState
import com.lambdadigamma.events.presentation.timetable.EventsUiState
import com.lambdadigamma.events.presentation.timetable.TimetableUiState
import dagger.Provides
import dagger.hilt.android.components.ViewModelComponent
import javax.inject.Singleton

@Module
@InstallIn(ViewModelComponent::class)
internal object EventsViewModelModule {

    @Provides
    fun provideInitialEventsUiState(): EventsUiState = EventsUiState(isLoading = true)

    @Provides
    fun provideInitialTimetableUiState(): TimetableUiState = TimetableUiState(isLoading = true)

    @Provides
    fun provideInitialFavoriteEventsUiState(): FavoriteEventsUiState = FavoriteEventsUiState(isLoading = true)

    @Provides
    fun provideInitialEventDetailUiState(): EventDetailUiState = EventDetailUiState(isLoading = true)

    @Provides
    fun provideInitialEventDownloadUiState(): DownloadEventsUiState = DownloadEventsUiState(isLoading = true)
}

@Module
@InstallIn(SingletonComponent::class)
internal interface EventsSingletonModule {

    @Singleton
    @Binds
    @IntoSet
    fun bindEventsNavigationFactory(factory: EventsNavigationFactory): NavigationFactory
}
