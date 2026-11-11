package com.lambdadigamma.rubbish.street

import android.content.Context
import androidx.compose.foundation.text.input.TextFieldState
import androidx.compose.foundation.text.input.setTextAndPlaceCursorAtEnd
import androidx.compose.runtime.snapshotFlow
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.geo.DefaultGeocodingService
import com.lambdadigamma.core.geo.GMSLocationService
import com.lambdadigamma.rubbish.RubbishCollectionStreet
import com.lambdadigamma.rubbish.RubbishRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.text.Normalizer
import java.util.Locale
import javax.inject.Inject

data class RubbishStreetPickerUiState(
    /** The search text that [streets] match. */
    val query: String = "",
    val streets: List<RubbishCollectionStreet> = emptyList(),
    val isLoading: Boolean = true,
    val loadingFailed: Boolean = false,
)

@HiltViewModel
class RubbishStreetPickerViewModel @Inject constructor(
    @param:ApplicationContext private val context: Context,
    private val rubbishRepository: RubbishRepository,
) : ViewModel() {

    /** The search text. The search field edits it directly, so typing never waits for the filtering. */
    val query = TextFieldState()
    private val loadingFailed = MutableStateFlow(false)

    val uiState: StateFlow<RubbishStreetPickerUiState> = combine(
        rubbishRepository.streets,
        snapshotFlow { query.text.toString() },
        loadingFailed,
    ) { streets, text, failed ->
        RubbishStreetPickerUiState(
            query = text,
            streets = filterStreets(streets, text),
            isLoading = streets.isEmpty() && !failed,
            loadingFailed = streets.isEmpty() && failed,
        )
    }
        .flowOn(Dispatchers.Default)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), RubbishStreetPickerUiState())

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            loadingFailed.value = false
            loadingFailed.value = rubbishRepository.refreshStreets().isFailure
        }
    }

    /** Stores [street] as the user's street and loads its pickups. */
    fun select(street: RubbishCollectionStreet, onSelected: () -> Unit) {
        viewModelScope.launch {
            rubbishRepository.setStreet(street.id, street.name)
            onSelected()
        }
    }

    /** Searches for the street at the current location. Requires a location permission. */
    fun useCurrentLocation() {
        viewModelScope.launch {
            val point = GMSLocationService(context).currentLocation() ?: return@launch
            DefaultGeocodingService(context).reverseGeocode(point).firstOrNull()?.street
                ?.takeIf { it.isNotBlank() }
                ?.let { query.setTextAndPlaceCursorAtEnd(it) }
        }
    }

    companion object {
        private const val MAX_RESULTS = 200

        fun filterStreets(streets: List<RubbishCollectionStreet>, query: String): List<RubbishCollectionStreet> {
            val needle = normalize(query)
            if (needle.isEmpty()) return streets.take(MAX_RESULTS)
            return streets
                .map { it to normalize(it.name) }
                .filter { (_, name) -> name.contains(needle) }
                .sortedWith(compareBy({ !it.second.startsWith(needle) }, { it.second }))
                .map { it.first }
                .take(MAX_RESULTS)
        }

        private val diacritics = "\\p{Mn}+".toRegex()

        private fun normalize(value: String): String =
            Normalizer.normalize(value.trim().lowercase(Locale.GERMAN), Normalizer.Form.NFD)
                .replace(diacritics, "")
                .replace("ß", "ss")
                .replace("strasse", "str")
                .replace("str.", "str")
    }
}
