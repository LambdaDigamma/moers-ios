package com.lambdadigamma.moersfestival.ui

import android.content.Context
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject

@Composable
fun LicensesRoute(onBack: () -> Unit) {
    val context = LocalContext.current
    val licenses = produceState<List<LicenseEntry>?>(initialValue = null, context) {
        value = withContext(Dispatchers.IO) {
            loadLicenses(context)
        }
    }

    LicensesScreen(
        onBack = onBack,
        licenses = licenses.value.orEmpty(),
        isLoading = licenses.value == null,
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LicensesScreen(
    onBack: () -> Unit,
    licenses: List<LicenseEntry>,
    isLoading: Boolean,
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(text = stringResource(com.lambdadigamma.moersfestival.R.string.licenses_title))
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = stringResource(com.lambdadigamma.core.R.string.navigation_back),
                        )
                    }
                },
            )
        },
    ) { padding ->
        when {
            isLoading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentAlignment = Alignment.Center,
                ) {
                    CircularProgressIndicator()
                }
            }

            licenses.isEmpty() -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding)
                        .padding(24.dp),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = stringResource(com.lambdadigamma.moersfestival.R.string.licenses_empty),
                        style = MaterialTheme.typography.bodyLarge,
                    )
                }
            }

            else -> {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    item {
                        Surface(
                            shape = RoundedCornerShape(28.dp),
                            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.35f),
                        ) {
                            Text(
                                text = stringResource(com.lambdadigamma.moersfestival.R.string.licenses_intro),
                                style = MaterialTheme.typography.bodyLarge,
                                modifier = Modifier.padding(20.dp),
                            )
                        }
                    }

                    items(licenses, key = { it.id }) { license ->
                        Surface(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(28.dp),
                            color = MaterialTheme.colorScheme.surface,
                            shadowElevation = 1.dp,
                        ) {
                            SelectionContainer {
                                Column(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(20.dp),
                                    verticalArrangement = Arrangement.spacedBy(12.dp),
                                ) {
                                    Text(
                                        text = license.framework,
                                        style = MaterialTheme.typography.titleLarge,
                                        fontWeight = FontWeight.SemiBold,
                                    )
                                    Text(
                                        text = license.name,
                                        style = MaterialTheme.typography.titleSmall,
                                        color = MaterialTheme.colorScheme.primary,
                                    )
                                    Text(
                                        text = license.text,
                                        style = MaterialTheme.typography.bodyMedium,
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private fun loadLicenses(context: Context): List<LicenseEntry> {
    return runCatching {
        val rawJson = context.resources
            .openRawResource(com.lambdadigamma.moersfestival.R.raw.aboutlibraries)
            .bufferedReader()
            .use { it.readText() }
        val root = JSONObject(rawJson)
        val licensesById = root.optJSONObject("licenses") ?: JSONObject()
        val libraries = root.optJSONArray("libraries") ?: JSONArray()

        buildList {
            for (index in 0 until libraries.length()) {
                val item = libraries.getJSONObject(index)
                val licenseIds = item.optJSONArray("licenses") ?: JSONArray()
                val resolvedLicenses = resolveLicenses(licenseIds, licensesById)
                val version = item.optString("artifactVersion")

                add(
                    LicenseEntry(
                        id = item.optString("uniqueId", item.optString("name")),
                        framework = item.optString("name", item.optString("uniqueId"))
                            .withVersion(version),
                        name = resolvedLicenses.names,
                        text = resolvedLicenses.text,
                    ),
                )
            }
        }
            .sortedBy { it.framework.lowercase() }
    }.getOrDefault(emptyList())
}

private fun resolveLicenses(
    licenseIds: JSONArray,
    licensesById: JSONObject,
): ResolvedLicense {
    val names = mutableListOf<String>()
    val texts = mutableListOf<String>()

    for (index in 0 until licenseIds.length()) {
        val licenseId = licenseIds.optString(index)
        val license = licensesById.optJSONObject(licenseId)
        names += license?.optString("name")?.takeIf { it.isNotBlank() } ?: licenseId
        texts += license?.optString("content")?.takeIf { it.isNotBlank() }
            ?: license?.optString("url")?.takeIf { it.isNotBlank() }
            ?: licenseId
    }

    return ResolvedLicense(
        names = names.distinct().joinToString(", ").ifBlank { "Unknown license" },
        text = texts.distinct().joinToString("\n\n"),
    )
}

private fun String.withVersion(version: String): String {
    return if (version.isBlank()) this else "$this $version"
}

private data class ResolvedLicense(
    val names: String,
    val text: String,
)

data class LicenseEntry(
    val id: String,
    val framework: String,
    val name: String,
    val text: String,
)
