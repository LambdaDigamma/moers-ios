package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost
import com.lambdadigamma.moers.settings.formatTime
import com.lambdadigamma.rubbish.notifications.rememberEnableReminders

/**
 * Offers waste collection reminders right after the street is chosen. Turning them on asks for
 * the notification permission. Declining it or skipping continues without reminders.
 */
@Composable
fun OnboardingRubbishRemindersScreen(onContinue: () -> Unit) {
    val viewModel: OnboardingRubbishRemindersViewModel = hiltViewModel()
    val reminderTime by viewModel.reminderTime.collectAsStateWithLifecycle()
    val enableReminders = rememberEnableReminders(
        onEnable = {
            viewModel.enableReminders()
            onContinue()
        },
        onDenied = onContinue,
    )

    OnboardingRubbishRemindersContent(
        reminderTime = formatTime(reminderTime.hour, reminderTime.minute),
        onEnable = enableReminders,
        onSkip = onContinue,
    )
}

@Composable
fun OnboardingRubbishRemindersContent(
    reminderTime: String,
    onEnable: () -> Unit,
    onSkip: () -> Unit,
) {
    OnboardingHost(
        content = {
            Column(
                modifier = Modifier
                    .padding(16.dp)
                    .fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Text(
                    text = stringResource(R.string.onboarding_rubbish_reminders_headline),
                    style = MaterialTheme.typography.titleLarge,
                )
                Text(
                    text = stringResource(R.string.onboarding_rubbish_reminders_body, reminderTime),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Text(
                    text = stringResource(R.string.onboarding_rubbish_reminders_hint),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    ) {
        Button(onClick = onEnable, modifier = Modifier.fillMaxWidth()) {
            Text(text = stringResource(R.string.onboarding_rubbish_reminders_enable))
        }
        TextButton(onClick = onSkip, modifier = Modifier.fillMaxWidth()) {
            Text(text = stringResource(R.string.onboarding_location_not_now_cta))
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun OnboardingRubbishRemindersPreview() {
    MeinMoersTheme {
        OnboardingRubbishRemindersContent(reminderTime = "20:00", onEnable = {}, onSkip = {})
    }
}
