package com.lambdadigamma.events.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.ui.ResourcefulContent
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.events.R

@Composable
fun EventOverviewScreen(onSelectEvent: (Int) -> Unit) {

    val viewModel: EventOverviewViewModel = hiltViewModel()
    val events = viewModel.loadOverview()

    Column(modifier = Modifier.fillMaxSize()) {

        TopBar(title = stringResource(R.string.navigation_top_bar))

        ResourcefulContent(resource = events, onLoad = { /*TODO*/ }) { it ->
            EventOverviewList(
                todayEvents = it.todayEvents,
                longTermEvents = it.longTermEvents,
                onSelectEvent = onSelectEvent
            )
        }

    }

}