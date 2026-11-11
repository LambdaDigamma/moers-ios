package com.lambdadigamma.moers.onboarding

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.rubbish.RubbishRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.time.LocalTime
import javax.inject.Inject

@HiltViewModel
class OnboardingRubbishRemindersViewModel @Inject constructor(
    private val rubbishRepository: RubbishRepository,
) : ViewModel() {

    /** The time on the evening before a collection at which the reminder arrives. */
    val reminderTime: StateFlow<LocalTime> = rubbishRepository.reminderTime
        .map { time -> LocalTime.of(time?.hours ?: DEFAULT_TIME.hour, time?.minutes ?: 0) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), DEFAULT_TIME)

    fun enableReminders() {
        viewModelScope.launch { rubbishRepository.setRemindersEnabled(true) }
    }

    private companion object {
        val DEFAULT_TIME: LocalTime = LocalTime.of(RubbishRepository.DEFAULT_REMINDER_HOUR, 0)
    }
}
