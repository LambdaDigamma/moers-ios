package com.lambdadigamma.moers

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.runtime.getValue
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.ui.App
import com.lambdadigamma.moers.ui.Onboarding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen().setKeepOnScreenCondition { viewModel.isOnboarded.value == null }
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        setContent {
            MeinMoersTheme {
                val isOnboarded by viewModel.isOnboarded.collectAsStateWithLifecycle()
                when (isOnboarded) {
                    true -> App()
                    false -> Onboarding()
                    null -> Unit
                }
            }
        }
    }

}
