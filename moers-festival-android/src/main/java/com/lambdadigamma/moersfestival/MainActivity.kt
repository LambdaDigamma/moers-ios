package com.lambdadigamma.moersfestival

import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.material3.ExperimentalMaterial3Api
import dagger.hilt.android.AndroidEntryPoint

@OptIn(ExperimentalMaterial3Api::class)
@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    private var incomingIntent by mutableStateOf<Intent?>(null)
    private var incomingIntentConsumed = false

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }
        super.onCreate(savedInstanceState)
        incomingIntentConsumed = savedInstanceState
            ?.getBoolean(KEY_INCOMING_INTENT_CONSUMED)
            ?: false
        incomingIntent = if (incomingIntentConsumed) null else intent

        setContent {
            App(
                incomingIntent = incomingIntent,
                onIncomingIntentConsumed = {
                    incomingIntentConsumed = true
                    incomingIntent = null
                },
            )
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        outState.putBoolean(KEY_INCOMING_INTENT_CONSUMED, incomingIntentConsumed)
        super.onSaveInstanceState(outState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        incomingIntentConsumed = false
        incomingIntent = intent
    }

    private companion object {
        const val KEY_INCOMING_INTENT_CONSUMED = "incoming_intent_consumed"
    }
}
