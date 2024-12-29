package com.lambdadigamma.fuel.data

import androidx.room.TypeConverter
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

object FuelStationConverters {

    private val gson = Gson()

    /**
     * Converts a JSON string to an List of FuelStationTimeEntry.
     *
     * @param value JSON string representation of the list
     * @return ArrayList<FuelStationTimeEntry>? or null if input is null
     */
    @TypeConverter
    fun fromJsonToTimeEntryList(value: String?): List<FuelStationTimeEntry>? {
        return if (value.isNullOrEmpty()) {
            null
        } else {
            val listType = object : TypeToken<List<FuelStationTimeEntry>>() {}.type
            gson.fromJson(value, listType)
        }
    }

    /**
     * Converts an List of FuelStationTimeEntry to a JSON string.
     *
     * @param list The list to convert
     * @return JSON string representation of the list or an empty JSON array if input is null
     */
    @TypeConverter
    fun fromTimeEntryListToJson(list: List<FuelStationTimeEntry>?): String {
        return gson.toJson(list ?: emptyList<FuelStationTimeEntry>())
    }

    /**
     * Converts a JSON string to a List of Strings.
     *
     * @param value JSON string representation of the list
     * @return List<String>? or null if input is null
     */
    @TypeConverter
    fun fromJsonToStringList(value: String?): List<String>? {
        return if (value.isNullOrEmpty()) {
            null
        } else {
            val listType = object : TypeToken<List<String>>() {}.type
            gson.fromJson(value, listType)
        }
    }

    /**
     * Converts a List of Strings to a JSON string.
     *
     * @param list The list to convert
     * @return JSON string representation of the list or an empty JSON array if input is null
     */
    @TypeConverter
    fun fromStringListToJson(list: List<String>?): String {
        return gson.toJson(list ?: emptyList<String>())
    }

}