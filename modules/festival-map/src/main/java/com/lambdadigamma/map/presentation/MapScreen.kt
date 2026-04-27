package com.lambdadigamma.map.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.MyLocation
import androidx.compose.material.icons.rounded.Refresh
import androidx.compose.material3.BottomSheetScaffold
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SheetValue
import androidx.compose.material3.Text
import androidx.compose.material3.rememberBottomSheetScaffoldState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.lambdadigamma.events.presentation.venue.composable.VenueDetailContent
import com.lambdadigamma.events.presentation.venue.composable.VenueDetailStateProvider
import com.lambdadigamma.map.R
import com.lambdadigamma.map.presentation.composable.BoothDetailContent
import com.lambdadigamma.map.presentation.composable.FestivalMapView
import com.lambdadigamma.map.presentation.composable.MapDrawerContent

@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun MapScreen(
    uiState: MapUiState,
    onIntent: (MapIntent) -> Unit,
    onShowEvent: (Int) -> Unit,
    hasLocationPermission: Boolean,
    onLocateMe: () -> Unit,
) {
    val scaffoldState = rememberBottomSheetScaffoldState()

    LaunchedEffect(uiState.selection?.stableId) {
        when (uiState.selection) {
            null -> { /* leave sheet where it is */ }
            is MapSelection.Feature,
            is MapSelection.Place,
            -> {
                if (scaffoldState.bottomSheetState.currentValue == SheetValue.Expanded) {
                    scaffoldState.bottomSheetState.partialExpand()
                }
            }
        }
    }

    BoxWithConstraints(modifier = Modifier.fillMaxSize()) {
        val sheetTopInset = maxHeight * 0.1f
        val drawerMinContentHeight = maxHeight - sheetTopInset
        val drawerCollapsedPeekHeight = (maxHeight * 0.14f).coerceIn(
            minimumValue = 112.dp,
            maximumValue = 132.dp,
        )
        val sheetPeekHeight = when (uiState.selection) {
            null -> drawerCollapsedPeekHeight
            is MapSelection.Feature -> 148.dp
            is MapSelection.Place -> 260.dp
        }

        Box(modifier = Modifier.fillMaxSize()) {
            FestivalMapView(
                uiState = uiState,
                onIntent = onIntent,
                hasLocationPermission = hasLocationPermission,
                modifier = Modifier.fillMaxSize(),
            )

            MapControlButtons(
                uiState = uiState,
                onRefresh = { onIntent(MapIntent.Refresh) },
                hasLocationPermission = hasLocationPermission,
                onLocateMe = onLocateMe,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .statusBarsPadding()
                    .padding(top = 12.dp, end = 16.dp),
            )

            BottomSheetScaffold(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(top = sheetTopInset),
                scaffoldState = scaffoldState,
                sheetPeekHeight = sheetPeekHeight,
                sheetDragHandle = { PassiveDragHandle() },
                containerColor = Color.Transparent,
                sheetContent = {
                    when (val selection = uiState.selection) {
                        null -> MapDrawerContent(
                            uiState = uiState,
                            onIntent = onIntent,
                            minContentHeight = drawerMinContentHeight,
                        )

                        is MapSelection.Feature -> BoothDetailContent(
                            feature = selection.value,
                            onDismiss = { onIntent(MapIntent.ClearSelection) },
                        )

                        is MapSelection.Place -> VenueDetailStateProvider(
                            placeId = selection.value.id,
                        ) { venueUiState ->
                            VenueDetailContent(
                                uiState = venueUiState,
                                onShowEvent = onShowEvent,
                                onDismiss = { onIntent(MapIntent.ClearSelection) },
                                useSectionContainers = false,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .heightIn(min = drawerMinContentHeight)
                                    .padding(vertical = 4.dp),
                            )
                        }
                    }
                },
            ) { _ ->
                Box(modifier = Modifier.fillMaxSize())
            }

            Box(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .statusBarsPadding()
                    .padding(top = 16.dp, start = 16.dp, end = 16.dp),
            ) {
                if (uiState.isRefreshing) {
                    LinearProgressIndicator(modifier = Modifier.fillMaxWidth())
                }
            }

            uiState.refreshError?.localizedMessage
                ?.takeIf { message -> message.isNotBlank() }
                ?.let { message ->
                    ElevatedCard(
                        modifier = Modifier
                            .align(Alignment.TopCenter)
                            .statusBarsPadding()
                            .padding(top = 64.dp, start = 16.dp, end = 16.dp),
                    ) {
                        Text(
                            text = stringResource(R.string.map_refresh_error, message),
                            modifier = Modifier.padding(16.dp),
                        )
                    }
                }

            uiState.locationError?.let {
                ElevatedCard(
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .statusBarsPadding()
                        .padding(top = 120.dp, start = 16.dp, end = 16.dp),
                ) {
                    Text(
                        text = stringResource(R.string.map_location_error),
                        modifier = Modifier.padding(16.dp),
                    )
                }
            }

            if (uiState.isLoading && uiState.layers.isEmpty()) {
                CircularProgressIndicator(
                    modifier = Modifier.align(Alignment.Center),
                    color = MaterialTheme.colorScheme.primary,
                )
            }
        }
    }
}

@Composable
private fun MapControlButtons(
    uiState: MapUiState,
    onRefresh: () -> Unit,
    hasLocationPermission: Boolean,
    onLocateMe: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(12.dp),
        horizontalAlignment = Alignment.End,
    ) {
        FilledIconButton(
            enabled = !uiState.isRefreshing,
            onClick = onRefresh,
        ) {
            Icon(
                imageVector = Icons.Rounded.Refresh,
                contentDescription = stringResource(R.string.map_refresh),
            )
        }

        FilledTonalIconButton(
            enabled = !uiState.isLocatingUser,
            onClick = onLocateMe,
        ) {
            if (uiState.isLocatingUser) {
                CircularProgressIndicator(
                    modifier = Modifier.size(20.dp),
                    strokeWidth = 2.dp,
                )
            } else {
                Icon(
                    imageVector = Icons.Rounded.MyLocation,
                    contentDescription = stringResource(
                        if (hasLocationPermission) {
                            R.string.map_locate_me
                        } else {
                            R.string.map_enable_location
                        },
                    ),
                )
            }
        }
    }
}

@Composable
private fun PassiveDragHandle() {
    Box(
        modifier = Modifier
            .padding(vertical = 8.dp)
            .width(52.dp)
            .height(6.dp)
            .background(
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.9f),
                shape = RoundedCornerShape(percent = 50),
            ),
    )
}
