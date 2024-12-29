package com.lambdadigamma.moers.onboarding

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.fuel.data.FuelRepository
import com.lambdadigamma.fuel.data.FuelType
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class OnboardingFuelViewModel @Inject constructor(
    @ApplicationContext val context: Context,
    private val fuelRepository: FuelRepository
) : ViewModel() {

    val fuelType = fuelRepository.fuelType

    fun updateFuelType(fuelType: FuelType) {
        viewModelScope.launch {
            fuelRepository.updateFuelType(fuelType)
        }
    }

}