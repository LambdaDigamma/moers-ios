package com.lambdadigamma.pages.data.di

import android.content.Context
import com.lambdadigamma.core.base.ServiceFactory
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerDeserializer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerSerializer
import com.lambdadigamma.pages.data.remote.api.PageService
import com.lambdadigamma.pages.data.remote.api.registerPageBlockTypeAdapter
import com.lambdadigamma.pages.data.repository.PageRepositoryImpl
import com.lambdadigamma.pages.domain.repository.PageRepository
import com.lambdadigamma.pages.domain.usecase.GetPageUseCase
import com.lambdadigamma.pages.domain.usecase.RefreshPageUseCase
import com.lambdadigamma.pages.domain.usecase.getPage
import com.lambdadigamma.pages.domain.usecase.refreshPage
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
internal object PageModule {

    @Provides
    @Singleton
    fun providePageApi(
        retrofit: Retrofit,
        @ApplicationContext context: Context
    ): PageService {
        return ServiceFactory.getService(
            baseUrl = "https://app.moers-festival.de/api/v1/",
            gsonBuilder = { gsonBuilder ->
                gsonBuilder
                    .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerDeserializer())
                    .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerSerializer())
                    .registerPageBlockTypeAdapter()
            },
            context = context
        )
    }

    @Provides
    fun provideGetPageUseCase(
        pageRepository: PageRepository,
    ): GetPageUseCase {
        return GetPageUseCase { id ->
            getPage(id, pageRepository)
        }
    }

    @Provides
    fun provideRefreshPageUseCase(
        pageRepository: PageRepository
    ): RefreshPageUseCase {
        return RefreshPageUseCase { id ->
            refreshPage(id, pageRepository)
        }
    }

    @Module
    @InstallIn(SingletonComponent::class)
    interface BindsModule {

        @Binds
        @Singleton
        fun bindPageRepository(impl: PageRepositoryImpl): PageRepository
    }
}
