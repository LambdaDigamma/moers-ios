package com.lambdadigamma.events.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.res.stringResource
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.lambdadigamma.core.ui.LargeTopBar
import com.lambdadigamma.core.ui.ResourcefulContent
import com.lambdadigamma.events.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventOverviewScreen(onSelectEvent: (Int) -> Unit) {

    val viewModel: EventOverviewViewModel = hiltViewModel()
    val events = remember(viewModel) { viewModel.loadOverview() }
    val scrollBehavior = TopAppBarDefaults.exitUntilCollapsedScrollBehavior()

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            LargeTopBar(
                title = stringResource(R.string.navigation_top_bar),
                scrollBehavior = scrollBehavior,
            )
        },
    ) { padding ->
        ResourcefulContent(
            resource = events,
            onLoad = {},
            modifier = Modifier.padding(padding),
        ) {
            EventOverviewList(
                todayEvents = it.todayEvents,
                longTermEvents = it.longTermEvents,
                onSelectEvent = onSelectEvent
            )
        }
    }
}
