package com.lambdadigamma.moers.database

import android.content.Context
import androidx.room.Room

object DatabaseCreator {

    fun database(context: Context): AppDatabase {
        return Room.databaseBuilder(context, AppDatabase::class.java, "meinmoers-db")
            .fallbackToDestructiveMigration()
            .build()
    }

}