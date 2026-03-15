package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Divider
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.NavController
import androidx.navigation.compose.currentBackStackEntryAsState
import com.lambdadigamma.moers.Destinations
import com.lambdadigamma.moers.onboarding.ui.OnboardingTopBar

@Composable
fun OnboardingTop(navController: NavController) {

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route
        ?: Destinations.Onboarding.welcome

    if (currentRoute != Destinations.Onboarding.welcome) {

        val onboardingStep = OnboardingStep.fromRoute(currentRoute)
        val state = onboardingStep?.toUiState()

        state?.let {
            Column(modifier = Modifier.fillMaxWidth()) {
                OnboardingTopBar(it)
                HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f))
            }
        }

    }
}