package com.lambdadigamma.events.presentation.timetable.composable

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import com.lambdadigamma.core.refresh.RefreshFailureMessageFormatter
import com.lambdadigamma.events.R

@Composable
fun TimetableError(
    modifier: Modifier = Modifier,
    throwable: Throwable,
    onRefresh: () -> Unit,
) {
    val context = LocalContext.current

    Column(modifier = modifier.fillMaxSize()) {

        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            Text(
                text = RefreshFailureMessageFormatter.format(
                    context = context,
                    throwable = throwable,
                ),
            )

            Button(onClick = { onRefresh() }) {
                Text(stringResource(R.string.timetable_retry))
            }

        }

    }

}
