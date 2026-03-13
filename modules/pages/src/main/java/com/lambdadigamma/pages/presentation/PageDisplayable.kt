package com.lambdadigamma.pages.presentation

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
class PageDisplayable(
    val id: Int,
    val title: String,
): Parcelable {
}