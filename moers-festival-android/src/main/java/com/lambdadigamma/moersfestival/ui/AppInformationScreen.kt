package com.lambdadigamma.moersfestival.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.ExperimentalTextApi
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.UrlAnnotation
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.R
import com.lambdadigamma.moersfestival.BuildConfig

@Composable
fun AppInformationRoute(onBack: () -> Unit) {

    AppInformationScreen(onBack = onBack)

}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalTextApi::class)
@Composable
fun AppInformationScreen(onBack: () -> Unit) {

    Scaffold(topBar = {
        TopAppBar(
            title = {
                Text(
                    text = stringResource(com.lambdadigamma.moersfestival.R.string.about_this_app),
                )
            },
            navigationIcon = {
                IconButton(onClick = onBack) {
                    Icon(
                        imageVector = Icons.Default.ArrowBack,
                        contentDescription = stringResource(R.string.navigation_back)
                    )
                }
            }
        )
    }) { padding ->

        Column(
            modifier = Modifier
                .padding(padding)
                .verticalScroll(rememberScrollState())
        ) {

            val versionCode = BuildConfig.VERSION_CODE
            val versionName = BuildConfig.VERSION_NAME

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                val text = buildAnnotatedString {
                    append(stringResource(com.lambdadigamma.moersfestival.R.string.app_information_paragraph1))
                    appendLine()
                    appendLine()
                    append(stringResource(com.lambdadigamma.moersfestival.R.string.app_information_paragraph2))
                    append("moers-festival.de")
                    this.pushStyle(
                        SpanStyle(
                            color = MaterialTheme.colorScheme.primary,
                            textDecoration = TextDecoration.Underline
                        )
                    )
                    this.addUrlAnnotation(
                        start = this.length,
                        end = this.length + "moers-festival.de".length,
                        urlAnnotation = UrlAnnotation("https://www.moers-festival.de")
                    )
                    appendLine()

                }

                BasicText(
                    text = text,
                    style = MaterialTheme.typography.bodyLarge.copy(
                        color = MaterialTheme.colorScheme.onBackground
                    )
                )

                BasicText(
                    text = "Version: $versionName ($versionCode)",
                    style = MaterialTheme.typography.bodyLarge.copy(
                        color = MaterialTheme.colorScheme.onBackground
                    )
                )

            }

        }
    }


}

@Preview(showSystemUi = true, showBackground = true)
@Composable
private fun AppInformationScreenPreview() {
    AppInformationScreen(onBack = {})
}