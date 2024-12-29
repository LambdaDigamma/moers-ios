package com.lambdadigamma.events.ui

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable

@Composable
fun SubtitleEventText() {

    val isLive = true

    if (isLive) {
        Text(text = "Live")
    } else {
        Text(text = "Upcoming")
    }
    
}