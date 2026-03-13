package com.lambdadigamma.map.presentation.di

import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.events.presentation.timetable.EventsUiState
import com.lambdadigamma.map.presentation.MapNavigationFactory
import com.lambdadigamma.map.presentation.MapUiState
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
internal object MapViewModelModule {

    @Provides
    fun provideInitialMapUiState(): MapUiState = MapUiState(isLoading = true)

}

@Module
@InstallIn(SingletonComponent::class)
internal interface MapSingletonModule {

    @Singleton
    @Binds
    @IntoSet
    fun bindMapNavigationFactory(factory: MapNavigationFactory): NavigationFactory
}
