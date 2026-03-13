package com.lambdadigamma.moersfestival

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.lambdadigamma.core.ui.TopBar

@Composable
fun InfoScreen() {

    Scaffold(
        topBar = { TopBar(title = "Info") }
    ) { paddingValues ->
        Text("Info", modifier = Modifier.padding(paddingValues))
    }

}