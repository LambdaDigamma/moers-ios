package com.lambdadigamma.events.presentation.timetable.composable

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier

@Composable
fun TimetableError(
    modifier: Modifier = Modifier,
    throwable: Throwable,
    onRefresh: () -> Unit
) {

    Column(modifier = modifier.fillMaxSize()) {

        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            Text(throwable.localizedMessage ?: throwable.message ?: "Unknown error")

            Button(onClick = { onRefresh() }) {
                Text("Refresh")
            }

        }

    }

}