package com.lambdadigamma.core.ui

import androidx.compose.foundation.layout.RowScope
import androidx.compose.material3.SmallTopAppBar
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable

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
    SmallTopAppBar(
        title = { Text(title) },
        actions = actions
    )
}

