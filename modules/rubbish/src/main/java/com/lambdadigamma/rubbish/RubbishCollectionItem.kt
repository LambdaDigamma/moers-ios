package com.lambdadigamma.rubbish

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.text.SimpleDateFormat
import java.util.*

fun parseDate(date: String, format: String): Date? {

    val dateFormat = SimpleDateFormat(format, Locale.getDefault())
    return dateFormat.parse(date)

}

@Entity(tableName = "rubbish_collection_items")
data class RubbishCollectionItem(
    @PrimaryKey(autoGenerate = true) val id: Long,
    @ColumnInfo(name = "date") val date: String,
    @ColumnInfo(name = "type") val type: RubbishWasteType
) {

    val parsedDate: Date
        get() {
            return parseDate(date, "yyyy-MM-dd") ?: Date()
        }

}