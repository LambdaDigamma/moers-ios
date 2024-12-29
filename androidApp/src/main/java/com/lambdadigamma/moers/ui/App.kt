package com.lambdadigamma.moers.ui

import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.navigation.compose.rememberNavController
import com.google.accompanist.systemuicontroller.rememberSystemUiController
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.Destinations
import com.lambdadigamma.moers.NavGraph
import com.lambdadigamma.moers.OnboardingNavigationGraph

@OptIn(ExperimentalAnimationApi::class)
@ExperimentalMaterial3Api
@Composable
fun Onboarding(
    onFinishOnboarding: () -> Unit,
    finishActivity: () -> Unit,
) {
    MeinMoersTheme {
        val navController = rememberNavController()
        OnboardingNavigationGraph(
            navController = navController,
            onFinishOnboarding = onFinishOnboarding,
            finishActivity = finishActivity
        )
    }
}

@ExperimentalMaterial3Api
@Composable
fun App(finishActivity: () -> Unit) {
    MeinMoersTheme {
        val tabs = remember { AppTab.values() }
        val navController = rememberNavController()

        rememberSystemUiController().setNavigationBarColor(
            MaterialTheme.colorScheme.surfaceVariant
        )

        Scaffold(
            bottomBar = { BottomBar(navController = navController, tabs) },
            modifier = Modifier
                .navigationBarsPadding()
                .systemBarsPadding()
        ) { padding ->
            NavGraph(
                finishActivity = finishActivity,
                navController = navController,
                startDestination = Destinations.dashboard,
                modifier = Modifier.padding(padding)
            )
        }
    }
}