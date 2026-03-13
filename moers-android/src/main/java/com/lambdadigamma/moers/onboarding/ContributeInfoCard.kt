package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.moers.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ContributeInfoCard(modifier: Modifier = Modifier) {

    ElevatedCard(modifier = modifier) {

        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {

            Text(
                stringResource(R.string.onboarding_about_contribute_title),
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Medium
            )

            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {

                Text(
                    text = "Die App wird von Lennart Fischer konzeptioniert und entwickelt. Der gesamte Programmcode der App ist auf GitHub zu finden. Jede und jeder ist eingeladen, an der Entwicklung mitzuwirken oder Ideen einzubringen. Alle weiteren Helfer:innen sind in auch in der App zu finden.",
                    style = MaterialTheme.typography.bodyMedium
                )

                Text(
                    text = "Du möchtest auch mithelfen?",
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.SemiBold
                )

                Text(
                    text = "Super! Du kannst Deine Ideen oder Dein Wissen einbringen. Weitere Informationen findest Du hier.",
                    style = MaterialTheme.typography.bodyMedium,
                )

            }

            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Button(onClick = { /*TODO*/ }, enabled = false) {
                    Text(text = stringResource(R.string.onboarding_about_cta))
                }
                Text(
                    text = stringResource(R.string.onboarding_soon_disclaimer),
                    color = MaterialTheme.colorScheme.secondary,
                    style = MaterialTheme.typography.bodyMedium,
                )
            }

        }

    }

}

@Preview(showBackground = true)
@Composable
private fun ContributeInfoCardPreview() {
    MeinMoersTheme {
        ContributeInfoCard(modifier = Modifier.padding(16.dp))
    }
}