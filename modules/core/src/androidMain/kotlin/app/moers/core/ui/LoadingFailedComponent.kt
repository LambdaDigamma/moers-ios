package app.moers.core.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.google.accompanist.swiperefresh.SwipeRefresh
import com.google.accompanist.swiperefresh.rememberSwipeRefreshState
import app.moers.core.R
import app.moers.core.Resource
import app.moers.core.Status
import app.moers.core.theme.MeinMoersTheme
import kotlinx.coroutines.delay

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun <Data> ResourcefulContent(
    resource: LiveData<Resource<Data>>,
    onLoad: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable (Data) -> Unit
) {

    // Simulate a fake 2-second 'load'. Ideally this 'refreshing' value would
    // come from a ViewModel or similar
    var refreshing by remember { mutableStateOf(false) }
    LaunchedEffect(refreshing) {
        if (refreshing) {
            delay(2000)
            refreshing = false
        }
    }

    LaunchedEffect(key1 = "abc", block = {
//        onLoad()
    })

    val currentState by resource.observeAsState()
    val swipeRefreshState =
        rememberSwipeRefreshState(isRefreshing = currentState?.isLoading() ?: false)

    SwipeRefresh(
        state = swipeRefreshState,
        onRefresh = onLoad,
    ) {
        when (currentState?.status) {
            Status.LOADING -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize(),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
//                    CircularProgressIndicator()
                    Text(
                        text = "Lädt Abfallkalender...",
                        color = MaterialTheme.colorScheme.secondary
                    )
                }
            }
            Status.ERROR -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize(),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    ResourcefulErrorContent(error = currentState?.errorMessage ?: "")
                }
            }
            Status.SUCCESS -> {
                currentState?.data?.let {
                    content(it)
                }
//                    Text(text = "Success")
//                    Text(text = "Success: ${currentState.data}")
            }
            else -> {

            }
        }
//        Column(
//            modifier = Modifier
//                .fillMaxSize()
//                .verticalScroll(rememberScrollState())
//        ) {
//
//        }
    }

//
//    SwipeRefresh(
//        state = swipeRefreshState,
//        onRefresh = onLoad,
//    ) {
//        Column(
//            modifier = modifier
//                .scrollable(rememberScrollState(), orientation = Orientation.Vertical),
//        ) {
//
//            when (currentState?.status) {
//                Status.LOADING -> {
//                    Text(text = "Loading...")
//                }
//                Status.ERROR -> {
//                    Column(
//                        modifier = Modifier
//                            .fillMaxSize(),
//                        verticalArrangement = Arrangement.Center,
//                        horizontalAlignment = Alignment.CenterHorizontally
//                    ) {
//                        ResourcefulErrorContent(error = currentState?.errorMessage ?: "")
//                    }
//                }
//                Status.SUCCESS -> {
//                    currentState?.data?.let {
//                        content(it)
//                    }
////                    Text(text = "Success")
////                    Text(text = "Success: ${currentState.data}")
//                }
//                else -> {
//
//                }
//            }
//
//
////            ResourcefulErrorContent(error = error)
//        }
//    }
}

@Composable
private fun ResourcefulErrorContent(error: String) {
    Column(
        verticalArrangement = Arrangement.spacedBy(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(16.dp)
    ) {
        Icon(
            painter = painterResource(id = R.drawable.ic_outline_error_outline_24),
            contentDescription = null,
            modifier = Modifier.size(64.dp),
            tint = MaterialTheme.colorScheme.surfaceTint
        )
        Text(text = error)
//            TextButton(onClick = { /*TODO*/ }) {
//                Text(text = "Neu laden")
//            }
    }
}

@Preview
@Composable
fun LoadingFailedPreview() {

    val resource: Resource<String> = Resource.loading()
//    val resource: Resource<String> = Resource.success("Success")
//    val resource: Resource<String> = Resource.error("Error")
    val liveData = MutableLiveData(resource)

    MeinMoersTheme {
        ResourcefulContent(liveData, {
//            liveData.value = Resource.success("Success")
            liveData.value = Resource.error("Error")
        }, content = { Text(text = it) }, modifier = Modifier.fillMaxSize())
    }
}