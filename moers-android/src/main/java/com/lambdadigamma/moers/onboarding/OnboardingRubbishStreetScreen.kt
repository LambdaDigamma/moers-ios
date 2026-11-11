package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost
import com.lambdadigamma.rubbish.street.RubbishStreetPicker

@Composable
fun OnboardingRubbishStreetScreen(
    onContinue: () -> Unit
) {
    OnboardingHost(
        shouldScroll = false,
        content = {
            RubbishStreetPicker(
                onStreetSelected = onContinue,
                header = {
                    Text(
                        text = stringResource(R.string.onboarding_rubbish_street_selection_title),
                        style = MaterialTheme.typography.titleLarge,
                    )
                    Text(
                        text = stringResource(R.string.onboarding_rubbish_street_selection_body),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(top = 8.dp, bottom = 16.dp),
                    )
                },
            )
        }
    ) {
        TextButton(onClick = onContinue, modifier = Modifier.fillMaxWidth()) {
            Text(text = stringResource(R.string.onboarding_rubbish_street_skip_action))
        }
    }
}
