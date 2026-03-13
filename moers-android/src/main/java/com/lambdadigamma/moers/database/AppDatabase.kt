package com.lambdadigamma.moers.database

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.lambdadigamma.events.models.Event
import com.lambdadigamma.events.models.EventDao
import com.lambdadigamma.events.models.EventExtras
import com.lambdadigamma.fuel.data.FuelDao
import com.lambdadigamma.fuel.data.FuelStation
import com.lambdadigamma.fuel.data.FuelStationConverters
import com.lambdadigamma.newsfeature.data.NewsDao
import com.lambdadigamma.newsfeature.data.RssItem
import com.lambdadigamma.rubbish.RubbishCollectionItem
import com.lambdadigamma.rubbish.RubbishCollectionStreet
import com.lambdadigamma.rubbish.RubbishDao

@Database(
    entities = [
//    Entry::class,
//    Camera::class,
//    PetrolStation::class,
        FuelStation::class,
        Event::class,
        EventExtras::class,
        RssItem::class,
        RubbishCollectionStreet::class,
        RubbishCollectionItem::class
    ], version = 4, exportSchema = false
)
@TypeConverters(Converters::class, FuelStationConverters::class)
abstract class AppDatabase : RoomDatabase() {

    abstract fun newsDao(): NewsDao

    abstract fun rubbishDao(): RubbishDao

    abstract fun eventDao(): EventDao

    abstract fun fuelDao(): FuelDao

}