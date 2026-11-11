package com.lambdadigamma.core.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.CloudOff
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.lambdadigamma.core.R
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.Status
import com.lambdadigamma.core.theme.MeinMoersTheme

/**
 * Shows loading, error or loaded content for a [Resource] and supports pull to refresh.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun <Data> ResourcefulContent(
    resource: LiveData<Resource<Data>>,
    onLoad: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable (Data) -> Unit
) {
    val currentState by resource.observeAsState()
    val data = currentState?.data

    PullToRefreshBox(
        isRefreshing = currentState?.isLoading() == true && data != null,
        onRefresh = onLoad,
        modifier = modifier,
    ) {
        when {
            data != null -> content(data)
            currentState?.status == Status.ERROR -> ErrorContent(message = null, onRetry = onLoad)
            else -> LoadingContent()
        }
    }
}

/** Centered indeterminate progress indicator. */
@Composable
fun LoadingContent(modifier: Modifier = Modifier) {
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator()
    }
}

/** Centered error message with an optional retry button. */
@Composable
fun ErrorContent(
    message: String?,
    modifier: Modifier = Modifier,
    onRetry: (() -> Unit)? = null,
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Icon(
            imageVector = Icons.Outlined.CloudOff,
            contentDescription = null,
            modifier = Modifier.size(48.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Text(
            text = message?.takeIf { it.isNotBlank() } ?: stringResource(R.string.loading_failed),
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        if (onRetry != null) {
            FilledTonalButton(onClick = onRetry) {
                Text(stringResource(R.string.retry))
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun ErrorContentPreview() {
    MeinMoersTheme {
        ResourcefulContent(
            resource = MutableLiveData(Resource.error<String>("The data could not be loaded.")),
            onLoad = {},
            content = { Text(text = it) },
        )
    }
}
