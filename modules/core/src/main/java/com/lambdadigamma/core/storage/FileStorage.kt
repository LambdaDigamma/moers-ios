package com.lambdadigamma.core.storage

import android.content.Context

class FileStorage(private val context: Context) {

    fun getFile(fileName: String) {
        context.openFileInput(fileName)
    }

}