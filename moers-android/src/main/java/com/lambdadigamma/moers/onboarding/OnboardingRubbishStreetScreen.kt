package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
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
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
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
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.Status
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost
import kotlinx.coroutines.launch

@Composable
fun OnboardingRubbishStreetScreen(
    onContinue: () -> Unit
) {
    val viewModel = hiltViewModel<OnboardingRubbishViewModel>()
    val filteredStreets by viewModel.filteredStreets.observeAsState(initial = Resource.loading())
    val searchTerm by viewModel.searchTerm.collectAsState()
    val scope = rememberCoroutineScope()

    OnboardingRubbishStreetContent(
        searchTerm = searchTerm,
        filteredStreets = filteredStreets,
        onSelectStreet = viewModel::selectStreet,
        onUpdateSearchTerm = viewModel::updateSearchTerm,
        onLoadLocation = { scope.launch { viewModel.loadLocation() } },
        onContinue = onContinue
    )
}

@Composable
fun OnboardingRubbishStreetContent(
    searchTerm: String,
    filteredStreets: Resource<List<RubbishStreetUiState>>,
    onSelectStreet: (RubbishStreetUiState) -> Unit,
    onLoadLocation: () -> Unit,
    onUpdateSearchTerm: (String) -> Unit,
    onContinue: () -> Unit
) {
    val focusManager = LocalFocusManager.current

    OnboardingHost(
        shouldScroll = false,
        content = {
            StreetSearchHeader(
                searchTerm = searchTerm,
                onUpdateSearchTerm = onUpdateSearchTerm,
                onLoadLocation = onLoadLocation,
            )

            HorizontalDivider()

            if (filteredStreets.status == Status.SUCCESS) {
                LazyColumn(modifier = Modifier.fillMaxSize()) {
                    items(items = filteredStreets.data.orEmpty(), key = { it.id }) { street ->
                        ListItem(
                            headlineContent = { Text(street.streetName) },
                            supportingContent = street.addition
                                ?.takeIf { it.isNotBlank() }
                                ?.let { addition -> { Text(addition) } },
                            modifier = Modifier.clickable {
                                onSelectStreet(street)
                                focusManager.clearFocus()
                                onContinue()
                            },
                        )
                    }
                }
            }
        }
    ) {
        TextButton(onClick = onContinue, modifier = Modifier.fillMaxWidth()) {
            Text(text = stringResource(R.string.onboarding_rubbish_street_skip_action))
        }
    }
}

@Composable
private fun StreetSearchHeader(
    searchTerm: String,
    onLoadLocation: () -> Unit,
    onUpdateSearchTerm: (String) -> Unit
) {
    val focusManager = LocalFocusManager.current

    Column(
        modifier = Modifier
            .padding(16.dp)
            .fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Text(
            text = stringResource(R.string.onboarding_rubbish_street_selection_title),
            style = MaterialTheme.typography.titleLarge
        )
        Text(
            text = stringResource(R.string.onboarding_rubbish_street_selection_body),
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        OutlinedTextField(
            value = searchTerm,
            onValueChange = onUpdateSearchTerm,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp)
                .semantics { contentType = ContentType.AddressStreet },
            label = { Text(stringResource(R.string.onboarding_rubbish_street_placeholder)) },
            leadingIcon = { Icon(imageVector = Icons.Filled.Search, contentDescription = null) },
            trailingIcon = {
                IconButton(onClick = onLoadLocation) {
                    Icon(
                        imageVector = Icons.Outlined.MyLocation,
                        contentDescription = stringResource(R.string.onboarding_rubbish_street_use_location),
                    )
                }
            },
            singleLine = true,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
            keyboardActions = KeyboardActions(onSearch = { focusManager.clearFocus() }),
        )
    }
}

@Preview
@Composable
private fun OnboardingRubbishStreetScreenPreview() {
    MeinMoersTheme {
        var searchTerm by remember { mutableStateOf("") }
        val streets = listOf(
            RubbishStreetUiState(id = 1, streetName = "Bahnhofstraße"),
            RubbishStreetUiState(id = 2, streetName = "Hauptstraße", addition = "1–20"),
            RubbishStreetUiState(id = 3, streetName = "Friedrichstraße"),
        )
        OnboardingRubbishStreetContent(
            searchTerm = searchTerm,
            filteredStreets = Resource.success(streets),
            onSelectStreet = {},
            onLoadLocation = {},
            onUpdateSearchTerm = { searchTerm = it },
            onContinue = {}
        )
    }
}
