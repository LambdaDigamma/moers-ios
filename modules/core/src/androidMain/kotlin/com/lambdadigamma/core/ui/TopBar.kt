package com.lambdadigamma.core.ui

import androidx.compose.foundation.layout.RowScope
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TopBar(
    title: String,
    actions: @Composable RowScope.() -> Unit = {}
) {
//    LargeTopAppBar(
//        title = { Text(title) },
//        actions = actions
////        title = { Text(title) },
////        actions = actions
//    )
    TopAppBar(
        title = { Text(title) },
        actions = actions
    )
}

