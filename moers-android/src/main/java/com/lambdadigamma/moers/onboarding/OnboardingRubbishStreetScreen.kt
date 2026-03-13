package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.material.OutlinedTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.autofill.AutofillNode
import androidx.compose.ui.autofill.AutofillType
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.layout.boundsInWindow
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalAutofill
import androidx.compose.ui.platform.LocalAutofillTree
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.Status
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OnboardingRubbishStreetScreen(
    onContinue: () -> Unit
) {

    val viewModel = hiltViewModel<OnboardingRubbishViewModel>()
    val filteredStreets by viewModel.filteredStreets.observeAsState(
        initial = Resource.success(listOf(RubbishStreetUiState(1, "Adlerstraße")))
    )
    val searchTerm = viewModel.searchTerm.collectAsState()
    val scope = rememberCoroutineScope()

    OnboardingRubbishStreetContent(
        searchTerm = searchTerm,
        filteredStreets = filteredStreets,
        onSelectStreet = {
            viewModel.selectStreet(it)
        },
        onUpdateSearchTerm = {
            viewModel.updateSearchTerm(it)
        },
        onLoadLocation = {
            scope.launch {
                viewModel.loadLocation()
            }
        },
        onContinue = onContinue
    )

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OnboardingRubbishStreetContent(
    searchTerm: State<String>,
    filteredStreets: Resource<List<RubbishStreetUiState>>,
    onSelectStreet: (RubbishStreetUiState) -> Unit,
    onLoadLocation: () -> Unit,
    onUpdateSearchTerm: (String) -> Unit,
    onContinue: () -> Unit
) {

    OnboardingHost(
        shouldScroll = false,
        content = {

            Column(
                modifier = Modifier
                    .fillMaxSize(),
            ) {

                TopRubbishStreetSelection(
                    searchTerm = searchTerm,
                    onUpdateSearchTerm = onUpdateSearchTerm,
                    onLoadLocation = onLoadLocation,
                )

                Divider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f))

                val focusManager = LocalFocusManager.current

                if (filteredStreets.status == Status.SUCCESS) {
                    val data = filteredStreets.data.orEmpty()

                    Surface(tonalElevation = 1.dp) {
                        LazyColumn(
                            Modifier
                                .fillMaxHeight()
                                .fillMaxWidth(),
                            contentPadding = PaddingValues(vertical = 16.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            items(items = data) { street ->
                                Surface(
                                    modifier = Modifier
                                        .fillMaxWidth(),
                                    shadowElevation = 1.dp,
                                    tonalElevation = 0.dp,
                                    color = MaterialTheme.colorScheme.background,
                                    onClick = {
                                        onSelectStreet(street)
                                        focusManager.clearFocus()
                                        onContinue()
                                    }
                                ) {
                                    Column(
                                        modifier = Modifier
                                            .background(MaterialTheme.colorScheme.surface)
                                            .padding(
                                                vertical = 16.dp,
                                                horizontal = 16.dp
                                            )
                                    ) {
                                        Text(street.streetName, fontWeight = FontWeight.Medium)
                                        street.addition?.let {
                                            if (it.isNotEmpty()) {
                                                Text(
                                                    it,
                                                    color = MaterialTheme.colorScheme.secondary
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    ) {
        OnboardingRubbishStreetAction(action = {
            onContinue()
        })
    }

}

@OptIn(ExperimentalComposeUiApi::class)
@Composable
fun TopRubbishStreetSelection(
    searchTerm: State<String>,
    onLoadLocation: () -> Unit,
    onUpdateSearchTerm: (String) -> Unit
) {

    Column(
        modifier = Modifier
            .padding(16.dp)
            .fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp),
        horizontalAlignment = Alignment.Start
    ) {

        Text(
            text = stringResource(R.string.onboarding_rubbish_street_selection_title),
            textAlign = TextAlign.Left,
            fontWeight = FontWeight.SemiBold,
            style = MaterialTheme.typography.titleLarge
        )

        Text(
            text = stringResource(R.string.onboarding_rubbish_street_selection_body),
            textAlign = TextAlign.Left,
        )

        Spacer(modifier = Modifier.height(16.dp))

        val autofillNode = AutofillNode(
            autofillTypes = listOf(
//                AutofillType.PostalAddress,
//                AutofillType.AddressCountry,
//                AutofillType.AddressRegion,
                AutofillType.AddressStreet
            ),
            onFill = { onUpdateSearchTerm(it) }
        )

        val focusManager = LocalFocusManager.current
        val autofill = LocalAutofill.current

        LocalAutofillTree.current += autofillNode

        Row(
            modifier = Modifier
                .height(IntrinsicSize.Min)
                .fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {

            OutlinedTextField(
                modifier = Modifier
                    .weight(2f)
                    .onGloballyPositioned {
                        autofillNode.boundingBox = it.boundsInWindow()
                    }
                    .onFocusChanged { focusState ->
                        autofill?.run {
                            if (focusState.isFocused) {
                                requestAutofillForNode(autofillNode)
                            } else {
                                cancelAutofillForNode(autofillNode)
                            }
                        }
                    },
                value = searchTerm.value,
                label = {
                    Text(stringResource(R.string.onboarding_rubbish_street_placeholder))
                },
                onValueChange = { searchTerm ->
                    onUpdateSearchTerm(searchTerm)
                },
                singleLine = true,
                keyboardActions = KeyboardActions(
                    onDone = {
                        focusManager.clearFocus(true)
                    }
                ),
                leadingIcon = {
                    Icon(imageVector = Icons.Default.Search, contentDescription = "")
                }
            )

//            Spacer(modifier = Modifier.width(8.dp))
//
//            IconButton(onClick = {
//                onLoadLocation()
//            }) {
//                Icon(
//                    Icons.Filled.LocationOn,
//                    contentDescription = "Search current location",
//                    tint = MaterialTheme.colorScheme.primary,
//                )
//            }

        }
    }
}

@Composable
fun OnboardingRubbishStreetAction(action: () -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier.fillMaxWidth(),
    ) {
        TextButton(
            onClick = { action() },
            contentPadding = PaddingValues(16.dp),
        ) {
            Text(
                text = stringResource(R.string.onboarding_rubbish_street_skip_action),
                fontWeight = FontWeight.Bold,
                style = MaterialTheme.typography.bodyLarge
            )
        }
    }
}

@Preview
@Composable
fun OnboardingRubbishStreetScreen_Preview() {
    MeinMoersTheme {

        val searchTerm = remember {
            mutableStateOf("")
        }

        val streets = listOf<RubbishStreetUiState>(
            RubbishStreetUiState(
                id = 1,
                streetName = "Bahnhofstrasse",
            ),
            RubbishStreetUiState(
                id = 2,
                streetName = "Hauptstrasse",
            ),
            RubbishStreetUiState(
                id = 3,
                streetName = "Friedrichstrasse",
            ),
        )

        OnboardingRubbishStreetContent(
            searchTerm = searchTerm,
            filteredStreets = Resource.success(streets),
            onSelectStreet = {},
            onLoadLocation = { /*TODO*/ },
            onUpdateSearchTerm = { searchTerm.value = it },
            onContinue = {}
        )
    }
}