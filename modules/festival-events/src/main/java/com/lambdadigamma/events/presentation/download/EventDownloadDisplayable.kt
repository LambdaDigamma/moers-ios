package com.lambdadigamma.events.presentation.download

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class EventDownloadDisplayable(
    val id: Int,
    val name: String,
    val hasPageDownloaded: Boolean,
    val hasMediaDownloaded: Boolean
): Parcelable