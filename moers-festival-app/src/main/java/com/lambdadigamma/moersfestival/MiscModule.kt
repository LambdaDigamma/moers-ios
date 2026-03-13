package com.lambdadigamma.moersfestival

import com.lambdadigamma.core.navigation.NavigationFactory
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dagger.multibindings.IntoSet
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
internal interface MiscSingletonModule {

    @Singleton
    @Binds
    @IntoSet
    fun bindAppMetaNavigationFactory(factory: AppMetaNavigationFactory): NavigationFactory
}
