package com.lambdadigamma.moersfestival.database

import androidx.room.AutoMigration
import androidx.room.Database
import androidx.room.RenameColumn
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.room.migration.AutoMigrationSpec
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.lambdadigamma.core.Converters
import com.lambdadigamma.events.data.local.dao.EventConverter
import com.lambdadigamma.events.data.local.dao.EventDao
import com.lambdadigamma.events.data.local.dao.PlaceDao
import com.lambdadigamma.events.data.local.model.EventCached
import com.lambdadigamma.events.data.local.model.FavoriteEventCached
import com.lambdadigamma.events.data.local.model.LikedEventCached
import com.lambdadigamma.events.data.local.model.PlaceCached
import com.lambdadigamma.medialibrary.MediaDatabaseConverter
import com.lambdadigamma.news.data.local.dao.PostConverter
import com.lambdadigamma.news.data.local.dao.PostDao
import com.lambdadigamma.news.data.local.models.PostCached
import com.lambdadigamma.pages.data.local.dao.PageDao
import com.lambdadigamma.pages.data.local.model.PageBlockCached
import com.lambdadigamma.pages.data.local.model.PageCached

private const val DATABASE_VERSION = 8

// Migration from 1 to 2, Room 2.1.0.
val MIGRATION_1_2 = object : Migration(1, 2) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL(
            "ALTER TABLE events DROP COLUMN extras"
        )
        db.execSQL(
            "ALTER TABLE events ADD COLUMN extras TEXT"
        )
    }
}

// Migration from 6 to 7 - Remove RocketCached table as basic-feature module is removed
val MIGRATION_6_7 = object : Migration(6, 7) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL("DROP TABLE IF EXISTS RocketCached")
    }
}

val MIGRATION_7_8 = object : Migration(7, 8) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL("ALTER TABLE events ADD COLUMN collection TEXT")
    }
}

@TypeConverters(
    Converters::class,
    MediaDatabaseConverter::class,
    EventConverter::class,
    PostConverter::class
)
@Database(
    entities = [
        EventCached::class,
        FavoriteEventCached::class,
        LikedEventCached::class,
        PageCached::class,
        PageBlockCached::class,
        PlaceCached::class,
        PostCached::class,
   ],
    version = DATABASE_VERSION,
    autoMigrations = [
        AutoMigration(from = 2, to = 3),
        AutoMigration(from = 3, to = 4),
        AutoMigration(from = 4, to = 5),
        AutoMigration(from = 5, to = 6),
    ]
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun eventDao(): EventDao

    abstract fun pageDao(): PageDao

    abstract fun placeDao(): PlaceDao

    abstract fun postDao(): PostDao
}
