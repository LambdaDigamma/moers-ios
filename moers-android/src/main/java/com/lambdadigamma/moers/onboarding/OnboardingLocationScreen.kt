package com.lambdadigamma.moers.onboarding

import android.Manifest
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.google.accompanist.permissions.*
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost

@OptIn(ExperimentalMaterial3Api::class, ExperimentalPermissionsApi::class)
@Composable
fun OnboardingLocationScreen(
    onContinue: () -> Unit
) {

    // Fine location permission state
    val fineLocationPermissionState = rememberPermissionState(
        Manifest.permission.ACCESS_FINE_LOCATION
    )

    OnboardingLocationContent(
        onContinue = onContinue,
        fineLocationPermissionState = fineLocationPermissionState
    )

}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalPermissionsApi::class)
@Composable
fun OnboardingLocationContent(
    fineLocationPermissionState: PermissionState,
    onContinue: () -> Unit
) {
    OnboardingHost(
        content = {
            if (fineLocationPermissionState.status.isGranted) {
                LocationPermissionGranted()
            } else {
                LocationPermissionRequestPending()
            }
        }
    ) {
        OnboardingLocationBottomActions(
            onContinue = onContinue,
            fineLocationPermissionState = fineLocationPermissionState
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun LocationPermissionRequestPending() {

    Column(
        modifier = Modifier
            .background(MaterialTheme.colorScheme.background)
            .fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {

        Image(
            painter = painterResource(id = R.drawable.onboarding_location),
            contentDescription = null,
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 220.dp)
        )
        Column(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            horizontalAlignment = Alignment.Start
        ) {
            Text(
                text = stringResource(R.string.onboarding_location_info_title),
                textAlign = TextAlign.Left,
                fontWeight = FontWeight.SemiBold,
                style = MaterialTheme.typography.titleLarge
            )
            Text(
                text = stringResource(R.string.onboarding_location_info_intro),
                textAlign = TextAlign.Left
            )
            Text(
                text = stringResource(R.string.onboarding_location_info_transparency)
            )
        }

    }

    HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f))

    Surface(tonalElevation = 1.dp) {
        Column(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {

            ElevatedCard {
                Surface(tonalElevation = (-2).dp, shadowElevation = 2.dp) {
                    Column {

                        FeatureRow(
                            title = stringResource(R.string.location_reason_fuel_title),
                            text = stringResource(R.string.location_reason_fuel_text),
                            standalone = true
                        )

                        Divider(
                            color = MaterialTheme.colorScheme.onSurface.copy(
                                alpha = 0.12f
                            )
                        )

                        FeatureRow(
                            title = stringResource(R.string.location_reason_waste_schedule_title),
                            text = stringResource(R.string.location_reason_waste_schedule_text),
                            standalone = true
                        )

                    }
                }
            }

            ElevatedCard(
                modifier = Modifier.fillMaxWidth(),
            ) {
                Surface(tonalElevation = 4.dp) {
                    Column(modifier = Modifier.padding(16.dp)) {

                        Text(
                            text = stringResource(R.string.onboarding_location_no_location_disclaimer),
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
            }

        }
    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun LocationPermissionGranted() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.Start,
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 32.dp)
        ) {
            Image(
                imageVector = Icons.Default.CheckCircle,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                alignment = Alignment.Center,
                colorFilter = ColorFilter.tint(color = MaterialTheme.colorScheme.primary)
            )
        }
        Text(
            text = stringResource(R.string.onboarding_location_granted_title),
            fontWeight = FontWeight.SemiBold,
            style = MaterialTheme.typography.titleLarge
        )
        Text(
            text = stringResource(R.string.onboarding_location_granted_description),
            style = MaterialTheme.typography.bodyLarge,
            modifier = Modifier.fillMaxWidth()
        )
        Text(text = stringResource(R.string.onboarding_location_granted_undo))
    }
}

@OptIn(ExperimentalPermissionsApi::class)
@Composable
private fun OnboardingLocationBottomActions(
    onContinue: () -> Unit,
    fineLocationPermissionState: PermissionState
) {

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        when (fineLocationPermissionState.status) {
            PermissionStatus.Granted -> {
                Button(
                    onClick = {
                        onContinue()
                    },
                    modifier = Modifier.fillMaxWidth(),
                    contentPadding = PaddingValues(16.dp),
                ) {
                    Text(
                        text = stringResource(R.string.onboarding_location_continue),
                        fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.bodyLarge
                    )
                }
            }
            is PermissionStatus.Denied -> {
                Button(
                    onClick = {
                        fineLocationPermissionState.launchPermissionRequest()
                    },
                    modifier = Modifier.fillMaxWidth(),
                    contentPadding = PaddingValues(16.dp),
                ) {
                    Text(
                        text = stringResource(R.string.onboarding_location_enable_cta),
                        fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.bodyLarge
                    )
                }
                TextButton(onContinue) {
                    Text(stringResource(R.string.onboarding_location_not_now_cta))
                }
            }
        }
    }
}

@OptIn(ExperimentalPermissionsApi::class)
private class MockedPermissionState(
    override val permission: String
) : PermissionState {
    override val status: PermissionStatus
        get() = PermissionStatus.Granted

    override fun launchPermissionRequest() {
    }
}

@OptIn(ExperimentalPermissionsApi::class)
@Preview
@Composable
fun OnboardingLocationPreview() {
    MeinMoersTheme {
        val permissionState = MockedPermissionState("fine_location")
        Column(modifier = Modifier.fillMaxSize()) {
//            OnboardingTopBar(OnboardingTopBarUiState(
//                title = stringResource(R.string.onboarding_location_title),
//                subtitle = stringResource(R.string.onboarding_location_subtitle),
//                icon = R.drawable.onboarding_location
//            ))
            OnboardingLocationContent(
                onContinue = {},
                fineLocationPermissionState = permissionState
            )
        }
    }
}