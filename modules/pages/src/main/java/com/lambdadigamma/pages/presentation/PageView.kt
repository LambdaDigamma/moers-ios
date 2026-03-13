package com.lambdadigamma.pages.presentation

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel

@Composable
fun PageView(
    modifier: Modifier = Modifier,
    pageId: Int,
    /*hiltViewModel(
        creationCallback = { factory: PageViewModel.Factory ->
            factory.create(pageId)
        }
    ),*/
) {

    val viewModel: PageViewModel = viewModel()

//    Text(text = viewModel.pageId.toString())
    Text(text = "TEST")
    
//    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
//
//    uiState.page?.let { page ->
//
//        Text(text = page.id.toString())
//        Text(text = page.title)


//        PageBlockRenderer(
//            blocks = uiState.page
//        )

//    }



}