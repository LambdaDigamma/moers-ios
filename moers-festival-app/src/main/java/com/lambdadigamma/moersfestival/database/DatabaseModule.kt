package com.lambdadigamma.moersfestival.database

import android.content.Context
import androidx.room.Room
import com.lambdadigamma.events.data.local.dao.EventDao
import com.lambdadigamma.events.data.local.dao.PlaceDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import com.lambdadigamma.news.data.local.dao.PostDao
import com.lambdadigamma.pages.data.local.dao.PageDao
import javax.inject.Singleton

private const val APP_DATABASE_NAME = "moers_festival_db"

@Module
@InstallIn(SingletonComponent::class)
internal object DatabaseModule {

    @Singleton
    @Provides
    fun provideAppDatabase(
        @ApplicationContext context: Context,
    ): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            APP_DATABASE_NAME,
        )
            .addMigrations(MIGRATION_1_2, MIGRATION_6_7)
            .build()
    }

    @Singleton
    @Provides
    fun provideEventDao(database: AppDatabase): EventDao {
        return database.eventDao()
    }

    @Singleton
    @Provides
    fun providePageDao(database: AppDatabase): PageDao {
        return database.pageDao()
    }

    @Singleton
    @Provides
    fun providePlaceDao(database: AppDatabase): PlaceDao {
        return database.placeDao()
    }

    @Singleton
    @Provides
    fun providePostDao(database: AppDatabase): PostDao {
        return database.postDao()
    }
}
