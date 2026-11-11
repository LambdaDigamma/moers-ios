package com.lambdadigamma.rubbish

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.LocalDate
import java.time.format.DateTimeParseException

@Entity(tableName = "rubbish_collection_items")
data class RubbishCollectionItem(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    /** Pickup day in ISO format, for example `2026-11-12`. */
    @ColumnInfo(name = "date") val date: String,
    @ColumnInfo(name = "type") val type: RubbishWasteType
) {

    val localDate: LocalDate?
        get() = try {
            LocalDate.parse(date)
        } catch (_: DateTimeParseException) {
            null
        }

}
