package com.lambdadigamma.core.media

import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.net.Uri
import androidx.annotation.DrawableRes
import okhttp3.HttpUrl
import java.io.File

interface MediaImageDisplayable {

    /**
     * The default supported data types are:
     * - [String] (mapped to a [Uri])
     * - [Uri] ("android.resource", "content", "file", "http", and "https" schemes only)
     * - [HttpUrl]
     * - [File]
     * - [DrawableRes]
     * - [Drawable]
     * - [Bitmap]
     */
    fun data(width: Int, height: Int): Any

    fun contentDescription(): String?

}