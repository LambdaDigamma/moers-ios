package com.lambdadigamma.rubbish.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.SmallTopAppBar
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.core.ui.ResourcefulContent
import com.lambdadigamma.rubbish.R
import com.lambdadigamma.rubbish.RubbishScheduleViewModel
import kotlinx.coroutines.launch

@Composable
fun RubbishListScreen(onBack: () -> Unit) {

    val viewModel: RubbishScheduleViewModel = hiltViewModel()
    val rubbishSchedule = viewModel.rubbishCollectionItems

    LaunchedEffect(key1 = "load_rubbish_schedule") {
        viewModel.load()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
    ) {
        SmallTopAppBar(
            title = { Text(stringResource(R.string.rubbish_collection_title)) },
            navigationIcon = {
                NavigationBackButton(onBack = onBack)
            },
            actions = {
//                IconButton(onClick = { }) {
//                    Icon(Icons.Outlined.Info, "")
//                }
            }
        )

        ResourcefulContent(resource = rubbishSchedule, onLoad = {
            viewModel.viewModelScope.launch {
//                delay(2000)
                viewModel.load()
            }
        }) { list ->
            RubbishScheduleList(items = list.orEmpty())
        }
    }
}

@Preview
@Composable
fun RubbishListScreen_Preview() {
    MeinMoersTheme {
        RubbishListScreen(onBack = {})
    }
}