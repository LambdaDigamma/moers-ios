package com.lambdadigamma.map.data.di

import android.content.Context
import com.lambdadigamma.map.data.local.GeoDataLayerDatabase
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import retrofit2.Retrofit
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
internal object MapModule {

    @Provides
    @Singleton
    fun provideGeoDataLayerDatabase(
        @ApplicationContext context: Context
    ): GeoDataLayerDatabase {
        return GeoDataLayerDatabase(context)
    }

    @Module
    @InstallIn(SingletonComponent::class)
    interface BindsModule {

//        @Singleton
//        fun bindGeoDataLayerDatabase(): GeoDataLayerDatabase

//        @Binds
//        @Singleton
//        fun bindEventRepository(impl: EventRepositoryImpl): EventRepository
    }
}
