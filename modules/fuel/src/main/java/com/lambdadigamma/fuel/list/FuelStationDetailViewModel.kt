package com.lambdadigamma.fuel.list

import android.os.Build
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.Resource
import com.lambdadigamma.core.ui.AddressUiState
import com.lambdadigamma.core.ui.OpeningHoursEntry
import com.lambdadigamma.fuel.data.FuelRepository
import com.lambdadigamma.fuel.detail.FuelStationDetailUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import javax.inject.Inject

@HiltViewModel
class FuelStationDetailViewModel @Inject constructor(
    private val fuelRepository: FuelRepository
) : ViewModel() {

    lateinit var id: String

    private val _fuelStation = MutableLiveData<Resource<FuelStationDetailUiState>>()
    val fuelStation: LiveData<Resource<FuelStationDetailUiState>> get() = _fuelStation

    fun load() {
        viewModelScope.launch {
            fuelRepository.getFuelStation(id)
                .map { resource ->
                    resource.transform { station ->

                        return@transform FuelStationDetailUiState(
                            id = station.id,
                            brand = station.brand.trim(),
                            name = station.name.trim(),
                            point = station.coordinate,
                            price = station.price ?: 0.0,
                            distance = station.dist,
                            priceDiesel = station.diesel,
                            priceE5 = station.e5,
                            priceE10 = station.e10,
                            address = AddressUiState(
                                street = station.street,
                                houseNumber = station.houseNumber ?: "",
                                city = station.place,
                                state = station.state ?: "",
                                zip = station.postCode ?: ""
                            ),
                            openingHours = station.openingTimes.orEmpty().map {
                                val time = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    val timeFormat: DateTimeFormatter =
                                        DateTimeFormatter.ofPattern("HH:mm")
                                    val start = LocalTime.parse(it.start).format(timeFormat)
                                    val end = LocalTime.parse(it.end).format(timeFormat)
                                    "${start}-${end}"
                                } else {
                                    "${it.start}-${it.end}"
                                }
                                OpeningHoursEntry(
                                    label = it.text,
                                    value = time
                                )
                            },
                            isOpen = station.isOpen
                        )
                    }
                }.collect {
                    _fuelStation.value = it
                }

        }
    }

}