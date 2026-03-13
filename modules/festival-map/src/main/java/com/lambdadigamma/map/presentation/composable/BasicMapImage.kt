package com.lambdadigamma.map.presentation.composable

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.map.R
import soup.compose.photo.ExperimentalPhotoApi
import soup.compose.photo.PhotoBox
import soup.compose.photo.rememberPhotoState

@OptIn(ExperimentalPhotoApi::class)
@Composable
fun BasicMapImage() {

    val painter = painterResource(R.drawable.moers25_plan)
    val photoState = rememberPhotoState()

    photoState.setPhotoIntrinsicSize(painter.intrinsicSize)

    LaunchedEffect(key1 = "photoScale") {
        photoState.animateScale(2.5f)
    }

    Scaffold(topBar = {
        TopBar(title = "Map")
    }) {

        Box(
            modifier = Modifier
                .padding(top = it.calculateTopPadding())
                .background(Color.Black)
        ) {

            PhotoBox(
                state = photoState,
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center,
                propagateMinConstraints = false
            ) {
                Image(
                    painter,
                    contentDescription = "image",
                    modifier = Modifier.fillMaxSize(),
                )
            }

        }

    }



}