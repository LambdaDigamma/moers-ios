package com.lambdadigamma.news.data.di

import android.content.Context
import com.lambdadigamma.core.base.ServiceFactory
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerDeserializer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerSerializer
import com.lambdadigamma.news.data.remote.api.PostService
import com.lambdadigamma.news.data.repository.PostRepositoryImpl
import com.lambdadigamma.news.domain.repository.PostRepository
import com.lambdadigamma.news.domain.usecase.GetPostDetailUseCase
import com.lambdadigamma.news.domain.usecase.GetPostsUseCase
import com.lambdadigamma.news.domain.usecase.RefreshPostUseCase
import com.lambdadigamma.news.domain.usecase.RefreshPostsUseCase
import com.lambdadigamma.news.domain.usecase.getPostDetail
import com.lambdadigamma.news.domain.usecase.getPosts
import com.lambdadigamma.news.domain.usecase.refreshPost
import com.lambdadigamma.news.domain.usecase.refreshPosts
import com.lambdadigamma.pages.data.local.dao.PageDao
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
internal object NewsModule {

    @Provides
    @Singleton
    fun providePostApi(
        retrofit: Retrofit,
        @ApplicationContext context: Context
    ): PostService {
        return PostService.getMeinMoersService(context)
    }

    @Provides
    fun provideGetPostsUseCase(
        postRepository: PostRepository,
    ): GetPostsUseCase {
        return GetPostsUseCase {
            getPosts(postRepository)
        }
    }

    @Provides
    fun provideRefreshPostsUseCase(
        repository: PostRepository
    ): RefreshPostsUseCase {
        return RefreshPostsUseCase {
            refreshPosts(repository)
        }
    }

    @Provides
    fun provideRefreshPostUseCase(
        repository: PostRepository
    ): RefreshPostUseCase {
        return RefreshPostUseCase { id ->
            refreshPost(id, repository)
        }
    }

    @Provides
    fun provideGetPostDetailUseCase(
        repository: PostRepository,
    ): GetPostDetailUseCase {
        return GetPostDetailUseCase { id ->
            getPostDetail(
                postId = id,
                repository = repository
            )
        }
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
        fun bindPostRepository(impl: PostRepositoryImpl): PostRepository
    }

}
