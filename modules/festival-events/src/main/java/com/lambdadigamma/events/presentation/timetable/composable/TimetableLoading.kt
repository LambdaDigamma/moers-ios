package com.lambdadigamma.events.presentation.timetable.composable

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.lambdadigamma.core.ui.MoersFestivalTheme

@Composable
fun TimetableLoading() {

    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator()
    }

}

@Preview
@Composable
fun TimetableLoadingPreview() {

    MoersFestivalTheme {
        TimetableLoading()
    }

}