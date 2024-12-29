package com.lambdadigamma.moers.misc

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ContributeInfoCard
import com.lambdadigamma.moers.onboarding.OpenDataInfoCard

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutScreen(onBack: () -> Unit) {

    Scaffold(topBar = {
        SmallTopAppBar(
            title = {
                Text(text = stringResource(R.string.about_title))
            }, navigationIcon = {
                NavigationBackButton(onBack = onBack)
            }
        )
    }) {
        Column(
            modifier = Modifier
                .verticalScroll(rememberScrollState())
                .background(MaterialTheme.colorScheme.background)
                .padding(it)
                .padding(horizontal = 16.dp)
                .padding(top = 16.dp, bottom = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {

            OpenDataInfoCard()

            ContributeInfoCard()

        }

    }

}

@Preview
@Composable
fun AboutScreenPreview() {
    MaterialTheme {
        AboutScreen(onBack = {})
    }
}