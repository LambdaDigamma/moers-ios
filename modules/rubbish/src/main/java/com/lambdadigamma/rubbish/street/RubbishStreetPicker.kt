package com.lambdadigamma.rubbish.street

import android.Manifest
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.input.TextFieldLineLimits
import androidx.compose.foundation.text.input.TextFieldState
import androidx.compose.foundation.text.input.rememberTextFieldState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.outlined.MyLocation
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.autofill.ContentType
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentType
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.ErrorContent
import com.lambdadigamma.core.ui.LoadingContent
import com.lambdadigamma.rubbish.R
import com.lambdadigamma.rubbish.RubbishCollectionStreet

/**
 * Search field and list of all streets of the waste calendar. Selecting a street stores it
 * and calls [onStreetSelected].
 */
@Composable
fun RubbishStreetPicker(
    onStreetSelected: () -> Unit,
    modifier: Modifier = Modifier,
    header: @Composable ColumnScope.() -> Unit = {},
) {
    val viewModel: RubbishStreetPickerViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val locationPermission = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { result ->
        if (result.values.any { it }) viewModel.useCurrentLocation()
    }

    RubbishStreetPickerContent(
        uiState = uiState,
        queryState = viewModel.query,
        onSelect = { street -> viewModel.select(street, onStreetSelected) },
        onUseLocation = {
            locationPermission.launch(
                arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION)
            )
        },
        onRetry = viewModel::refresh,
        modifier = modifier,
        header = header,
    )
}

@Composable
fun RubbishStreetPickerContent(
    uiState: RubbishStreetPickerUiState,
    queryState: TextFieldState,
    onSelect: (RubbishCollectionStreet) -> Unit,
    onUseLocation: () -> Unit,
    onRetry: () -> Unit,
    modifier: Modifier = Modifier,
    header: @Composable ColumnScope.() -> Unit = {},
) {
    val focusManager = LocalFocusManager.current
    val listState = rememberLazyListState()

    // New results start at the best match instead of keeping the previous scroll position.
    LaunchedEffect(uiState.query) {
        listState.scrollToItem(0)
    }

    Column(modifier = modifier.fillMaxSize()) {
        Column(modifier = Modifier.padding(16.dp)) {
            header()
            OutlinedTextField(
                state = queryState,
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics { contentType = ContentType.AddressStreet },
                placeholder = { Text(stringResource(R.string.rubbish_street_search_placeholder)) },
                leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
                trailingIcon = {
                    IconButton(onClick = onUseLocation) {
                        Icon(
                            Icons.Outlined.MyLocation,
                            contentDescription = stringResource(R.string.rubbish_street_search_use_location),
                        )
                    }
                },
                lineLimits = TextFieldLineLimits.SingleLine,
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                onKeyboardAction = { focusManager.clearFocus() },
            )
        }
        HorizontalDivider()

        when {
            uiState.isLoading -> LoadingContent()
            uiState.loadingFailed -> ErrorContent(message = null, onRetry = onRetry)
            uiState.streets.isEmpty() -> Text(
                text = stringResource(R.string.rubbish_street_search_empty),
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(16.dp),
            )
            else -> LazyColumn(state = listState, modifier = Modifier.fillMaxSize()) {
                items(uiState.streets, key = { it.id }) { street ->
                    ListItem(
                        headlineContent = { Text(street.name) },
                        supportingContent = street.streetAddition
                            ?.takeIf { it.isNotBlank() }
                            ?.let { addition -> { Text(addition) } },
                        modifier = Modifier.clickable {
                            focusManager.clearFocus()
                            onSelect(street)
                        },
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun RubbishStreetPickerPreview() {
    MeinMoersTheme {
        RubbishStreetPickerContent(
            uiState = RubbishStreetPickerUiState(
                query = "Adler",
                streets = listOf(
                    RubbishCollectionStreet(7, "Adlerstraße", null, 3, 2, 8, 9, 2, null, 2026),
                    RubbishCollectionStreet(8, "Ahornweg", "1–15", 3, 2, 8, 9, 2, null, 2026),
                ),
                isLoading = false,
            ),
            queryState = rememberTextFieldState("Adler"),
            onSelect = {},
            onUseLocation = {},
            onRetry = {},
        )
    }
}
