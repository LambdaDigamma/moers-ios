package com.lambdadigamma.core.utils

import android.content.Context
import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.*


class LastUpdate(private val key: String, private val context: Context) {

    private val preferences: SharedPreferences =
        context.getSharedPreferences("lastUpdate", Context.MODE_PRIVATE)

    private val dateFormat = SimpleDateFormat("MM/dd/yyyy HH:mm:ss", Locale.US)

    fun set(lastUpdate: Date?) {
        var newDateString = ""
        if (lastUpdate != null) {
            newDateString = dateFormat.format(lastUpdate)
        }
        preferences.edit()
            .putString("lastUpdate$key", newDateString).apply()
    }

    fun get(): Date? {
        val dateString = preferences.getString("lastUpdate$key", "")
        dateString?.let {
            return if (it.isNotBlank()) {
                dateFormat.parse(dateString)
            } else {
                null
            }
        }
        return null
    }

}