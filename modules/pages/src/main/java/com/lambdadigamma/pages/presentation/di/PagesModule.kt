package com.lambdadigamma.pages.presentation.di

import com.lambdadigamma.pages.presentation.PageUiState
import com.lambdadigamma.pages.presentation.PageViewUiState
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ViewModelComponent

@Module
@InstallIn(ViewModelComponent::class)
internal object PagesViewModelModule {

    @Provides
    fun provideInitialPageUiState(): PageUiState = PageUiState()

    @Provides
    fun provideInitialPageViewUiState(): PageViewUiState = PageViewUiState()

}