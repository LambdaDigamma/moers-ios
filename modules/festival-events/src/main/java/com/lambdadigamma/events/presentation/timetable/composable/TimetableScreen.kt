package com.lambdadigamma.events.presentation.timetable.composable

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.MediumTopAppBar
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.events.R
import com.lambdadigamma.events.presentation.timetable.TimetableIntent
import com.lambdadigamma.events.presentation.timetable.TimetableUiState

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun TimetableScreen(
    uiState: TimetableUiState,
    onIntent: (TimetableIntent) -> Unit,
    onShowAppInformation: () -> Unit = {},
    onShowDownload: () -> Unit = {},
    pagerState: PagerState,
    currentIndex: MutableState<Int>
) {

    LaunchedEffect(key1 = "refreshTimetable", block = {
//        onIntent(TimetableIntent.GetEvents)
    })

    var expanded by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            MediumTopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.timetable),
                        style = MaterialTheme.typography.headlineSmall.copy(
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Black
                        )
                    )
                },
                actions = {
                    IconButton(onClick = onShowDownload) {
                        Icon(
                            painter = painterResource(id = R.drawable.baseline_download_24),
                            contentDescription = stringResource(R.string.download_timetable)
                        )
                    }
                    IconButton(onClick = { expanded = true }) {
                        Icon(
                            Icons.Default.MoreVert,
                            contentDescription = stringResource(R.string.more)
                        )
                    }
                    Box(
                        modifier = Modifier
                            .wrapContentSize(Alignment.TopEnd)
                    ) {
                        DropdownMenu(
                            expanded = expanded,
                            onDismissRequest = { expanded = false }
                        ) {
//                            DropdownMenuItem(
//                                text = { Text(stringResource(R.string.download_timetable)) },
//                                onClick = onShowDownload
//                            )
//                            Divider()
                            DropdownMenuItem(
                                text = { Text(stringResource(R.string.about_this_app)) },
                                onClick = { onShowAppInformation() }
                            )
                        }
                    }
                }
            )
        },
//        snackbarHost = { SnackbarHost(snackbarHostState) },
    ) { it ->

        TimetableContent(
            modifier = Modifier.padding(top = it.calculateTopPadding()),
            uiState = uiState,
            onIntent = onIntent,
            pagerState = pagerState,
            currentIndex = currentIndex
        )

    }
    
}

@OptIn(ExperimentalFoundationApi::class)
@Preview
@Composable
private fun TimetableScreenPreview() {
    MoersFestivalTheme() {
        TimetableScreen(
            uiState = TimetableUiState(),
            onIntent = {},
            pagerState = rememberPagerState(
                initialPage = 0,
                initialPageOffsetFraction = 0f,
                pageCount = { 10 }
            ),
            currentIndex = mutableStateOf(0)
        )
    }
}