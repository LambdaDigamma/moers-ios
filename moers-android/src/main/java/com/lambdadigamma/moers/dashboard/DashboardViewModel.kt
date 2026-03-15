package com.lambdadigamma.moers.dashboard

import androidx.lifecycle.ViewModel
import com.lambdadigamma.core.user.UserRepository
import com.lambdadigamma.core.user.UserType
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.map
import javax.inject.Inject

@HiltViewModel
class DashboardViewModel @Inject constructor(
    private val userRepository: UserRepository
) : ViewModel() {

    val userType = userRepository.userType
    val isVisitor = userType.map { it == UserType.VISITOR }
    val isCitizen = userType.map { it == UserType.CITIZEN }

}