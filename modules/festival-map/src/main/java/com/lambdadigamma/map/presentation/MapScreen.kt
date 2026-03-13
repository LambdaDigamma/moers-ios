package com.lambdadigamma.map.presentation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.lambdadigamma.map.presentation.composable.Map
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.map.R

@Composable
fun MapScreen(
    uiState: MapUiState
) {

    Scaffold(topBar = {
        TopBar(title = stringResource(R.string.map_title))
    }) {

        Box(modifier = Modifier.padding(top = it.calculateTopPadding())) {

            Map(modifier = Modifier.fillMaxSize())

        }

    }

}