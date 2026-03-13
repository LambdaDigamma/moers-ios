package com.lambdadigamma.moers.ui

import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.material3.BottomAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults.topAppBarColors
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
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
        val tabs = remember { AppTab.entries.toTypedArray() }
        val navController = rememberNavController()

        Scaffold(
            bottomBar = { BottomBar(navController = navController, tabs) },
            modifier = Modifier.fillMaxSize(),
//                .navigationBarsPadding()
//                .systemBarsPadding()
        ) { padding ->
            NavGraph(
                finishActivity = finishActivity,
                navController = navController,
                startDestination = Destinations.dashboard,
                modifier = Modifier.padding(bottom = padding.calculateBottomPadding())
            )
        }
    }
}