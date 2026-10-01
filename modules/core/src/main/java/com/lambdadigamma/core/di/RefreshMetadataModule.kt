package com.lambdadigamma.core.di

import com.lambdadigamma.core.refresh.DefaultRefreshMetadataStore
import com.lambdadigamma.core.refresh.RefreshMetadataStore
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
internal interface RefreshMetadataModule {

    @Binds
    @Singleton
    fun bindRefreshMetadataStore(
        store: DefaultRefreshMetadataStore,
    ): RefreshMetadataStore
}
