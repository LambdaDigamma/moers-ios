package com.lambdadigamma.events.data.di

import android.content.Context
import com.lambdadigamma.core.base.ServiceFactory
import com.lambdadigamma.events.data.remote.api.EventService
import com.lambdadigamma.events.data.repository.EventRepositoryImpl
import com.lambdadigamma.events.domain.repository.EventRepository
import com.lambdadigamma.events.domain.usecase.DownloadContentUseCase
import com.lambdadigamma.events.domain.usecase.GetEventDetailUseCase
import com.lambdadigamma.events.domain.usecase.GetEventsUseCase
import com.lambdadigamma.events.domain.usecase.GetFavoriteEventsUseCase
import com.lambdadigamma.events.domain.usecase.GetTimetableUseCase
import com.lambdadigamma.events.domain.usecase.RefreshEventsUseCase
import com.lambdadigamma.events.domain.usecase.ToggleFavoriteEventUseCase
import com.lambdadigamma.events.domain.usecase.downloadContent
import com.lambdadigamma.events.domain.usecase.getEventDetail
import com.lambdadigamma.events.domain.usecase.getEvents
import com.lambdadigamma.events.domain.usecase.getFavoriteEvents
import com.lambdadigamma.events.domain.usecase.getTimetable
import com.lambdadigamma.events.domain.usecase.refreshEvents
import com.lambdadigamma.events.domain.usecase.toggleFavoriteEvent
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerDeserializer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerSerializer
import com.lambdadigamma.pages.data.local.dao.PageDao
import com.lambdadigamma.pages.data.remote.api.PageService
import com.lambdadigamma.pages.data.remote.api.registerPageBlockTypeAdapter
import com.lambdadigamma.pages.data.repository.PageRepositoryImpl
import com.lambdadigamma.pages.domain.repository.PageRepository
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
internal object EventModule {

    @Provides
    @Singleton
    fun providePageApi(
        retrofit: Retrofit,
        @ApplicationContext context: Context
    ): PageService {
        return ServiceFactory.getService(
            baseUrl = "https://moers.app/api/v1/festival/",
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
    @Singleton
    fun providePageRepository(
        pageService: PageService,
        pageDao: PageDao
    ): PageRepository {
        return PageRepositoryImpl(
            pageApi = pageService,
            pageDao = pageDao
        )
    }

    @Provides
    @Singleton
    fun provideEventApi(
        retrofit: Retrofit,
        @ApplicationContext context: Context
    ): EventService {
        return EventService.getMeinMoersService(context)
//        return retrofit.create(EventService::class.java)
    }

    @Provides
    fun provideGetEventsUseCase(
        eventRepository: EventRepository,
    ): GetEventsUseCase {
        return GetEventsUseCase {
            getEvents(eventRepository)
        }
    }

    @Provides
    fun provideGetTimetableUseCase(
        eventRepository: EventRepository,
    ): GetTimetableUseCase {
        return GetTimetableUseCase {
            getTimetable(eventRepository)
        }
    }

    @Provides
    fun provideRefreshEventsUseCase(
        eventRepository: EventRepository
    ): RefreshEventsUseCase {
        return RefreshEventsUseCase {
            refreshEvents(eventRepository)
        }
    }

    @Provides
    fun provideDownloadContentUseCase(
        eventRepository: EventRepository
    ): DownloadContentUseCase {
        return DownloadContentUseCase {
            downloadContent(eventRepository)
        }
    }

    @Provides
    fun provideGetEventDetailUseCase(
        eventRepository: EventRepository,
    ): GetEventDetailUseCase {
        return GetEventDetailUseCase { id ->
            getEventDetail(
                eventId = id,
                eventRepository = eventRepository
            )
        }
    }

    @Provides
    fun provideGetFavoriteEventsUseCase(
        eventRepository: EventRepository,
    ): GetFavoriteEventsUseCase {
        return GetFavoriteEventsUseCase {
            getFavoriteEvents(eventRepository)
        }
    }

    @Provides
    fun provideToggleFavoriteUseCase(
        eventRepository: EventRepository,
    ): ToggleFavoriteEventUseCase {
        return ToggleFavoriteEventUseCase {
            toggleFavoriteEvent(it, eventRepository)
        }
    }

    @Module
    @InstallIn(SingletonComponent::class)
    interface BindsModule {

        @Binds
        @Singleton
        fun bindEventRepository(impl: EventRepositoryImpl): EventRepository
    }
}
