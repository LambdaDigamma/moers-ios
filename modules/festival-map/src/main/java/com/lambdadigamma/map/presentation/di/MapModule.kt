package com.lambdadigamma.map.presentation.di

import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.map.data.remote.api.FGDService
import com.lambdadigamma.map.data.remote.api.RetrofitClient
import com.lambdadigamma.map.data.repository.DefaultFestivalMapRepository
import com.lambdadigamma.map.data.repository.FestivalMapRepository
import com.lambdadigamma.map.data.source.AndroidFestivalMapAssetSource
import com.lambdadigamma.map.data.source.AndroidFestivalMapCacheSource
import com.lambdadigamma.map.data.source.AndroidFestivalMapRefreshTracker
import com.lambdadigamma.map.data.source.DefaultFestivalMapRemoteSource
import com.lambdadigamma.map.data.source.FestivalMapAssetSource
import com.lambdadigamma.map.data.source.FestivalMapCacheSource
import com.lambdadigamma.map.data.source.FestivalMapRefreshTracker
import com.lambdadigamma.map.data.source.FestivalMapRemoteSource
import com.lambdadigamma.map.presentation.MapNavigationFactory
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dagger.multibindings.IntoSet
import java.time.Clock
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
internal interface MapSingletonModule {

    @Binds
    fun bindMapRepository(repository: DefaultFestivalMapRepository): FestivalMapRepository

    @Binds
    fun bindAssetSource(source: AndroidFestivalMapAssetSource): FestivalMapAssetSource

    @Binds
    fun bindCacheSource(source: AndroidFestivalMapCacheSource): FestivalMapCacheSource

    @Binds
    fun bindRefreshTracker(tracker: AndroidFestivalMapRefreshTracker): FestivalMapRefreshTracker

    @Binds
    fun bindRemoteSource(source: DefaultFestivalMapRemoteSource): FestivalMapRemoteSource

    @Singleton
    @Binds
    @IntoSet
    fun bindMapNavigationFactory(factory: MapNavigationFactory): NavigationFactory
}

@Module
@InstallIn(SingletonComponent::class)
internal object MapServiceModule {

    @Provides
    @Singleton
    fun provideFgdService(): FGDService {
        return RetrofitClient.retrofit.create(FGDService::class.java)
    }

    @Provides
    @Singleton
    fun provideClock(): Clock {
        return Clock.systemDefaultZone()
    }
}
