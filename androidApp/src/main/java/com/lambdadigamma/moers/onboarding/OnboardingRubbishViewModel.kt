package com.lambdadigamma.moers.onboarding

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.*
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.geo.DefaultGeocodingService
import com.lambdadigamma.core.geo.GMSLocationService
import com.lambdadigamma.core.geo.GeocodingService
import com.lambdadigamma.moers.Application
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.launch
import javax.inject.Inject

fun <T> LiveData<T>.asFlow(): Flow<T> = callbackFlow {
    val observer = Observer<T> { value -> this.trySend(value).isSuccess }
    observeForever(observer)
    awaitClose {
        removeObserver(observer)
    }
}.flowOn(Dispatchers.Main.immediate)

@HiltViewModel
class OnboardingRubbishViewModel @Inject constructor(
    private val rubbishRepository: com.lambdadigamma.rubbish.RubbishRepository
) : ViewModel() {

    var uiState by mutableStateOf(OnboardingRubbishUiState())
        private set

    private var _list = MutableLiveData<List<RubbishStreetUiState>>()
    val list: LiveData<List<RubbishStreetUiState>>
        get() = _list

    var filteredStreets: MutableLiveData<Resource<List<RubbishStreetUiState>>> =
        MutableLiveData(Resource.loading())

    private var locationService: GMSLocationService
    private var geocodingService: GeocodingService
    private var loadingJob: Job? = null

    init {
        this.locationService = GMSLocationService(Application.instance)
        this.geocodingService = DefaultGeocodingService(Application.instance)
    }

    val searchTerm = MutableStateFlow("")

    fun updateSearchTerm(searchTerm: String) {
        this.searchTerm.value = searchTerm
        this.load(searchTerm = searchTerm)
    }

    fun load(searchTerm: String? = null) {

        loadingJob?.cancel()
        loadingJob = viewModelScope.launch {
            rubbishRepository.getRubbishStreets(streetName = searchTerm).asFlow()
                .collect { resource ->
                    val transformed = resource.transform { streets ->
                        streets.orEmpty().map { street ->
                            RubbishStreetUiState(
                                street.id,
                                street.name,
                                street.streetAddition
                            )
                        }
                    }
                    filteredStreets.postValue(transformed)
                }
        }

    }

    suspend fun loadLocation() {

        locationService.loadLastLocation()?.let { point ->
            val address = geocodingService.reverseGeocode(point)
            Log.d("ViewModels", "address: $address")
            address.firstOrNull()?.let { geocodedAddress ->
                this.load(geocodedAddress.street)
                this.searchTerm.value = geocodedAddress.street
            }
        }

    }

    fun selectStreet(street: RubbishStreetUiState) {
        viewModelScope.launch {
            rubbishRepository.setStreet(street.id, street.streetName)
        }
    }

}