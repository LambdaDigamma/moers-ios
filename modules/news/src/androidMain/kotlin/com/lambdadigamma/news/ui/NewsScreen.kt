package com.lambdadigamma.newsfeature.ui

import android.os.Build
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.lambdadigamma.core.DateUtils
import com.lambdadigamma.core.Status
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.newsfeature.R
import com.lambdadigamma.newsfeature.data.NewsListViewModel
import java.time.format.FormatStyle


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewsScreen(onShowRssItem: (Int) -> Unit) {

    val viewModel: NewsListViewModel = hiltViewModel()
    val news by viewModel.news.observeAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
//            .scrollable(rememberScrollState(), orientation = Orientation.Horizontal)
    ) {
        TopBar(
            title = stringResource(id = R.string.navigation_news),
        )

        when (news?.status) {
            Status.SUCCESS -> {

                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    items(news?.data ?: emptyList(), key = { it.guid }) { item ->

                        Card(onClick = {
                            item.id?.let(onShowRssItem)
                        }) {
                            Column() {
                                AsyncImage(
                                    model = item.image,
                                    contentDescription = null,
                                    alignment = Alignment.TopCenter,
                                    contentScale = ContentScale.FillWidth,
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .aspectRatio(ratio = (16.0f / 9.0f))
                                )

                                Column(
                                    modifier = Modifier.padding(12.dp),
                                    verticalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Text(
                                        text = item.title,
                                        fontWeight = FontWeight.SemiBold,
                                        style = MaterialTheme.typography.bodyMedium.copy(
                                            lineHeight = 18.sp,
                                        )
                                    )
                                    item.date?.let { date ->
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                            Text(
                                                text = DateUtils.format(date, FormatStyle.FULL),
                                                style = MaterialTheme.typography.bodyMedium
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Status.LOADING -> {
                NewsLoadingScreen()
            }
            Status.ERROR -> {
                NewsErrorScreen(error = news?.errorMessage ?: "")
            }
            else -> {

            }
        }
    }
}

@Composable
fun NewsLoadingScreen() {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Column(
            verticalArrangement = Arrangement.spacedBy(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            CircularProgressIndicator()
            Text(text = stringResource(R.string.news_list_loading_text))
        }
    }
}

@Preview
@Composable
fun NewsLoadingScreenPreview() {
    MeinMoersTheme {
        NewsLoadingScreen()
    }
}

@Composable
fun NewsErrorScreen(error: String) {
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Column(
            verticalArrangement = Arrangement.spacedBy(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(16.dp)
        ) {
            Icon(
                painter = painterResource(id = R.drawable.ic_outline_error_outline_24),
                contentDescription = stringResource(R.string.news_list_error_description),
                modifier = Modifier.size(64.dp),
                tint = MaterialTheme.colorScheme.surfaceTint
            )
            Text(text = error)
//            TextButton(onClick = { /*TODO*/ }) {
//                Text(text = "Neu laden")
//            }
        }
    }
}

@Preview
@Composable
fun NewsErrorScreenPreview() {
    MeinMoersTheme {
        NewsErrorScreen("Die Daten konnten nicht geladen werden.")
    }
}