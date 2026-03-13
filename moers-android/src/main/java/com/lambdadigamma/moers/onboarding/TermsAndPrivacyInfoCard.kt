package com.lambdadigamma.moers.onboarding

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.Global
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TermsAndPrivacyInfoCard(modifier: Modifier = Modifier) {

    ElevatedCard(modifier = modifier) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                stringResource(R.string.onboarding_about_terms_title),
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Medium
            )

            Text(
                text = stringResource(R.string.onboarding_privacy_card_info),
                style = MaterialTheme.typography.bodyMedium
            )
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.fillMaxWidth(),
            ) {

                val context = LocalContext.current
                val termsIntent = remember {
                    Intent(
                        Intent.ACTION_VIEW,
                        Uri.parse(Global.termsUrl)
                    )
                }
                val privacyIntent = remember {
                    Intent(
                        Intent.ACTION_VIEW,
                        Uri.parse(Global.privacyUrl)
                    )
                }

                OutlinedButton(onClick = {
                    context.startActivity(termsIntent)
                }) {
                    Text(stringResource(R.string.onboarding_privacy_terms))
                }

                OutlinedButton(onClick = {
                    context.startActivity(privacyIntent)
                }) {
                    Text(stringResource(R.string.onboarding_privacy_privacy))
                }

            }
        }
    }

}

@Preview(showBackground = true)
@Composable
private fun TermsAndPrivacyInfoCardPreview() {
    MeinMoersTheme {
        TermsAndPrivacyInfoCard(modifier = Modifier.padding(16.dp))
    }
}