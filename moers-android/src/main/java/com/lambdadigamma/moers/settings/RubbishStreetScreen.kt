package com.lambdadigamma.moers.settings

import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.lambdadigamma.core.ui.TopBar
import com.lambdadigamma.rubbish.R
import com.lambdadigamma.rubbish.street.RubbishStreetPicker

/** Lets the user change the street of the waste calendar. */
@Composable
fun RubbishStreetScreen(onBack: () -> Unit) {
    Scaffold(
        topBar = { TopBar(title = stringResource(R.string.rubbish_street_search_title), onBack = onBack) },
    ) { padding ->
        RubbishStreetPicker(
            onStreetSelected = onBack,
            modifier = Modifier
                .padding(padding)
                .consumeWindowInsets(padding)
                .imePadding(),
        )
    }
}
