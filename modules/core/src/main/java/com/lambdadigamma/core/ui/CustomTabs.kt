package com.lambdadigamma.core.ui

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.browser.customtabs.CustomTabColorSchemeParams
import androidx.browser.customtabs.CustomTabsIntent
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext

/**
 * Returns a function that opens web pages in a Custom Tab tinted with the current theme.
 * Falls back to any app that can view the URL when no Custom Tabs browser is installed.
 */
@Composable
fun rememberOpenUrl(): (String) -> Unit {
    val context = LocalContext.current
    val toolbarColor = MaterialTheme.colorScheme.surfaceContainer.toArgb()
    return remember(context, toolbarColor) {
        { url -> context.openInCustomTab(url, toolbarColor) }
    }
}

fun Context.openInCustomTab(url: String, toolbarColor: Int? = null) {
    val uri = Uri.parse(url)
    val intent = CustomTabsIntent.Builder()
        .setShowTitle(true)
        .setShareState(CustomTabsIntent.SHARE_STATE_ON)
        .apply {
            toolbarColor?.let {
                setDefaultColorSchemeParams(
                    CustomTabColorSchemeParams.Builder().setToolbarColor(it).build()
                )
            }
        }
        .build()
    try {
        intent.launchUrl(this, uri)
    } catch (_: ActivityNotFoundException) {
        try {
            startActivity(Intent(Intent.ACTION_VIEW, uri).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        } catch (_: ActivityNotFoundException) {
            // No browser is installed.
        }
    }
}
