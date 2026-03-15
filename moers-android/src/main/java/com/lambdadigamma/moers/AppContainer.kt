package com.lambdadigamma.moers

import android.content.Context
import com.lambdadigamma.moers.onboarding.OnboardingRepository

class AppContainer(context: Context) {

    val onboardingRepository: OnboardingRepository = OnboardingRepository(context)

}