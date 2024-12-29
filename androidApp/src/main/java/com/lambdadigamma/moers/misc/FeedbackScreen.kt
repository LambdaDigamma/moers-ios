package com.lambdadigamma.moers.misc

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.core.utils.findActivity
import com.lambdadigamma.moers.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FeedbackScreen(onBack: () -> Unit) {

    val viewModel: FeedbackViewModel = hiltViewModel()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(stringResource(R.string.feedback_title))
                }, navigationIcon = {
                    NavigationBackButton(onBack = onBack)
                }
            )
        }
    ) { paddingValues ->

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {

            FeedbackCard()

            ReviewCard(onReview = { viewModel.startReview(it) })

            Column {
                Text(
                    text = stringResource(R.string.feedback_disclaimer_line1),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.secondary
                )
                Text(
                    text = stringResource(R.string.feedback_disclaimer_line2),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.secondary
                )
            }

        }

    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FeedbackCard() {
    val context = LocalContext.current

    ElevatedCard() {

        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {

            Text(
                text = stringResource(R.string.feedback_card_title),
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Medium
            )

            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {

                Text(
                    text = stringResource(R.string.feedback_card_line1),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Normal
                )
                Text(
                    text = stringResource(R.string.feedback_card_line2),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Normal
                )
                Text(
                    text = stringResource(R.string.feedback_card_line3),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Normal
                )

            }

            val mailSubject = stringResource(R.string.feedback_card_mail_subject)
            val mailAddress = stringResource(R.string.feedback_card_mail_address)

            OutlinedButton(onClick = {
                val intent = Intent(Intent.ACTION_SENDTO)

                intent.putExtra(
                    Intent.EXTRA_SUBJECT,
                    mailSubject
                )
                intent.data = Uri.parse(mailAddress)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

                ContextCompat.startActivity(context, intent, null)
            }) {
                Text(text = stringResource(R.string.send_feedback_action))
            }

        }

    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReviewCard(onReview: (Activity) -> Unit) {
    ElevatedCard() {

        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {

            Text(
                text = stringResource(R.string.rate_app_headline),
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Medium
            )

            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {

                Text(
                    text = stringResource(R.string.rate_app_line1),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Normal
                )
                Text(
                    text = stringResource(R.string.rate_app_line2),
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Normal
                )

            }

            val activity = LocalContext.current.findActivity()

            OutlinedButton(onClick = {
                onReview(activity)
            }) {
                Text(text = stringResource(R.string.rate_app_action))
            }

        }

    }
}

@Preview
@Composable
fun FeedbackScreenPreview() {
    MaterialTheme {
        FeedbackScreen(onBack = {})
    }
}