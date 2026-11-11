package com.lambdadigamma.moers.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.user.UserRepository
import com.lambdadigamma.core.user.UserType
import com.lambdadigamma.fuel.data.FuelRepository
import com.lambdadigamma.fuel.data.FuelType
import com.lambdadigamma.rubbish.RubbishRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SettingsUiState(
    val userType: UserType = UserRepository.defaultUserType,
    val fuelType: FuelType = FuelRepository.defaultFuelType,
    val rubbishStreetName: String? = null,
    val remindersEnabled: Boolean = false,
    val reminderHours: Int = 20,
    val reminderMinutes: Int = 0,
)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val userRepository: UserRepository,
    private val fuelRepository: FuelRepository,
    private val rubbishRepository: RubbishRepository,
) : ViewModel() {

    val uiState: StateFlow<SettingsUiState> = combine(
        userRepository.userType,
        fuelRepository.fuelType,
        rubbishRepository.currentStreet,
        rubbishRepository.reminderEnabled,
        rubbishRepository.reminderTime,
    ) { userType, fuelType, street, remindersEnabled, reminderTime ->
        SettingsUiState(
            userType = userType,
            fuelType = fuelType,
            rubbishStreetName = street?.name,
            remindersEnabled = remindersEnabled,
            reminderHours = reminderTime?.hours ?: 20,
            reminderMinutes = reminderTime?.minutes ?: 0,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), SettingsUiState())

    fun updateUserType(userType: UserType) {
        viewModelScope.launch { userRepository.updateUserType(userType) }
    }

    fun updateFuelType(fuelType: FuelType) {
        viewModelScope.launch { fuelRepository.updateFuelType(fuelType) }
    }

    fun setRemindersEnabled(enabled: Boolean) {
        viewModelScope.launch { rubbishRepository.setRemindersEnabled(enabled) }
    }

    fun setReminderTime(hours: Int, minutes: Int) {
        viewModelScope.launch { rubbishRepository.setReminderTime(hours, minutes) }
    }

}
