package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost

@Composable
fun OnboardingAboutScreen(
    onContinue: () -> Unit,
) {

    OnboardingHost(
        content = {
            Column(
                modifier = Modifier
                    .padding(horizontal = 16.dp)
                    .padding(top = 16.dp, bottom = 16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {

                OpenDataInfoCard()

                ContributeInfoCard()

                TermsAndPrivacyInfoCard()

            }
        }
    ) {

        Column(
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Button(
                onClick = onContinue,
                modifier = Modifier
                    .fillMaxWidth(),
                contentPadding = PaddingValues(16.dp),
            ) {
                Text(
                    text = stringResource(R.string.onboarding_privacy_continue_button),
                    fontWeight = FontWeight.Bold,
                    style = MaterialTheme.typography.bodyLarge
                )
            }

            Text(
                text = stringResource(R.string.onboarding_privacy_consent),
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onBackground,
                style = MaterialTheme.typography.bodyMedium
            )
        }
    }

}
