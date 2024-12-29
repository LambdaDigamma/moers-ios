package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.fuel.data.FuelRepository
import com.lambdadigamma.fuel.data.FuelType
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost

@Composable
@ExperimentalMaterial3Api
fun OnboardingFuelScreen(
    onContinue: () -> Unit
) {

    val viewModel: OnboardingFuelViewModel = hiltViewModel()
    val selectedFuelType =
        viewModel.fuelType.collectAsState(initial = FuelRepository.defaultFuelType)

    LaunchedEffect(key1 = "InitialOnboardingFuelSetup", block = {
        viewModel.updateFuelType(FuelRepository.defaultFuelType)
    })

    OnboardingFuelContent(
        selectedFuelType = selectedFuelType,
        onUpdateFuelType = {
            viewModel.updateFuelType(it)
        },
        onContinue = onContinue
    )

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OnboardingFuelContent(
    selectedFuelType: State<FuelType>,
    onUpdateFuelType: (FuelType) -> Unit,
    onContinue: () -> Unit
) {

    val selectedFuelType = remember {
        mutableStateOf(selectedFuelType.value)
    }

    OnboardingHost(
        content = {

            Column(
                modifier = Modifier
                    .fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {

//                Image(
//                    painter = painterResource(id = R.drawable.onboarding_location),
//                    contentDescription = null,
//                    modifier = Modifier.fillMaxWidth()
//                )

                Column(
                    modifier = Modifier
                        .padding(16.dp)
                        .fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    horizontalAlignment = Alignment.Start
                ) {

                    Text(
                        text = "Wähle einen Kraftstofftyp",
                        textAlign = TextAlign.Left,
                        fontWeight = FontWeight.SemiBold,
                        style = MaterialTheme.typography.titleLarge
                    )

                    Text(
                        text = "Die App kann Dir einen Überblick über die aktuellen Krafstoffpreise geben. Wähle dazu Deinen bevorzugten Kraftstofftyp aus und fahre fort.",
                        textAlign = TextAlign.Left,
                    )

                    Column() {
                        FuelType.values().forEach { fuelType ->
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {

                                RadioButton(
                                    selected = selectedFuelType.value == fuelType,
                                    onClick = {
                                        selectedFuelType.value = fuelType
                                        onUpdateFuelType(fuelType)
                                    }
                                )

                                Text(text = fuelType.localizedName())

                            }
                        }
                    }
                }
            }
        }
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Button(
                onClick = onContinue,
                modifier = Modifier.fillMaxWidth(),
                contentPadding = PaddingValues(16.dp),
            ) {
                Text(
                    text = "Weiter",
                    fontWeight = FontWeight.Bold,
                    style = MaterialTheme.typography.bodyLarge
                )
            }
        }
    }

}

@Preview
@Composable
@ExperimentalMaterial3Api
private fun OnboardingFuelPreview() {
    val currentFuelType = remember {
        mutableStateOf(FuelType.DIESEL)
    }

    MeinMoersTheme {
        OnboardingFuelContent(
            selectedFuelType = currentFuelType,
            onUpdateFuelType = { currentFuelType.value = it },
            onContinue = {}
        )
    }
}