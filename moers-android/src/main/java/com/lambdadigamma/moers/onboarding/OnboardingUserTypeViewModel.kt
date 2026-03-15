package com.lambdadigamma.moers.onboarding

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.user.UserRepository
import com.lambdadigamma.core.user.UserType
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class OnboardingUserTypeViewModel @Inject constructor(
    private val userRepository: UserRepository
) : ViewModel() {

    val userType: Flow<UserType> = userRepository.userType

    fun updateUserType(userType: UserType) {
        viewModelScope.launch {
            userRepository.updateUserType(userType)
        }
    }

}