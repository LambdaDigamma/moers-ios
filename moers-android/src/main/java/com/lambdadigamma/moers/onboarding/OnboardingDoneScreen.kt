package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost

@Composable
fun OnboardingDoneScreen(onContinue: () -> Unit) {

    OnboardingHost(
        shouldScroll = false,
        content = {
            Column(
                modifier = Modifier
                    .fillMaxSize(1F)
                    .background(color = MaterialTheme.colorScheme.background)
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Image(
                    painter = painterResource(id = R.drawable.ic_baseline_check_24),
                    contentScale = ContentScale.FillBounds,
                    colorFilter = ColorFilter.tint(Color.Green),
                    contentDescription = "Checkmark",
                    modifier = Modifier
                        .width(128.dp)
                        .aspectRatio(1f)
                )
                Text(
                    text = stringResource(R.string.onboarding_done_headline),
                    style = MaterialTheme.typography.headlineLarge.copy(fontWeight = FontWeight.Bold),
                )
                Text(
                    text = stringResource(id = R.string.onboarding_done_text),
                    textAlign = TextAlign.Center,
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Normal),
                    modifier = Modifier.padding(top = 16.dp, bottom = 16.dp)
                )
            }

        },
        bottomContent = {
            Button(
                onClick = onContinue,
                modifier = Modifier.fillMaxWidth(),
                contentPadding = PaddingValues(16.dp),
            ) {
                Text(
                    text = stringResource(R.string.onboarding_done_cta),
                    fontWeight = FontWeight.Bold,
                    style = MaterialTheme.typography.bodyLarge
                )
            }
        }
    )

}

@Preview
@Composable
fun OnboardingDoneScreenPreview() {
    MeinMoersTheme {
        OnboardingDoneScreen(onContinue = {})
    }
}