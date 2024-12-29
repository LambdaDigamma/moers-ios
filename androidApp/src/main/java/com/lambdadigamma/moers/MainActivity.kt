package com.lambdadigamma.moers

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.core.view.WindowCompat
import androidx.lifecycle.lifecycleScope
import com.lambdadigamma.moers.onboarding.OnboardingActivity
import com.lambdadigamma.moers.onboarding.OnboardingRepository
import com.lambdadigamma.moers.ui.App
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var onboardingRepository: OnboardingRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

//        DynamicColors.applyIfAvailable(this)
//        window.navigationBarColor = SurfaceColors.SURFACE_0.getColor(this)
//        window.isNavigationBarContrastEnforced = false

//        window.navigationBarColor = SurfaceColors.SURFACE_2.getColor(this)


        WindowCompat.setDecorFitsSystemWindows(window, false)

        lifecycleScope.launch {
            onboardingRepository.isOnboarded.collect { isOnboarded ->
                Log.d("MainActivity", "isOnboarded: $isOnboarded")
                if (!isOnboarded) {
                    startOnboarding()
                } else {
                    setMainContent()
                }
            }
        }
    }

    private fun startOnboarding() {
        val intent = Intent(this, OnboardingActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_TASK_ON_HOME
        startActivity(intent)
        finish()
    }

    @OptIn(ExperimentalMaterial3Api::class)
    private fun setMainContent() {
        setContent {
            App {
                finish()
            }
        }
    }

}