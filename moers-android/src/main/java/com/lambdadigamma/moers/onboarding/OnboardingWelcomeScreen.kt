package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R

@Composable
fun OnboardingWelcomeScreen(onNext: () -> Unit) {

    Surface(color = MaterialTheme.colorScheme.background) {

        Column(
            modifier = Modifier
                .padding(horizontal = 16.dp)
                .padding(top = 32.dp, bottom = 48.dp)
                .background(MaterialTheme.colorScheme.background)
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Bottom,
        ) {

            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(32.dp)
            ) {

                Image(
                    painter = painterResource(id = R.drawable.onboarding_logo),
                    contentDescription = "App Icon",
                    modifier = Modifier.widthIn(0.dp, 160.dp)
                )

                Spacer(modifier = Modifier.height(0.dp))

                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {

                    Text(
                        text = stringResource(id = R.string.app_name),
                        textAlign = TextAlign.Center,
                        fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.headlineLarge
                    )

                    Text(
                        text = stringResource(R.string.onboarding_welcome_text),
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.bodyLarge
                    )

                }

                Button(
                    onClick = onNext,
                    modifier = Modifier
                        .fillMaxWidth(),
                    contentPadding = PaddingValues(16.dp),
                ) {
                    Text(
                        stringResource(R.string.onboarding_start_button),
                        fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.bodyLarge
                    )
                }

            }

        }
    }

}

@Preview
@Composable
fun OnboardingWelcomeScreenPreview() {
    MeinMoersTheme {
        OnboardingWelcomeScreen(onNext = {})
    }
}