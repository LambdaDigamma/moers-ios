package com.lambdadigamma.events.ui

import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.lambdadigamma.core.Resource
import com.lambdadigamma.events.models.Event
import com.lambdadigamma.events.models.EventRepository
import com.lambdadigamma.events.models.MeinMoersService
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

data class EventOverviewUiState(
    val todayEvents: List<EventUi>,
    val longTermEvents: List<EventUi>,
)

@HiltViewModel
class EventOverviewViewModel @Inject constructor(
    private val eventRepository: EventRepository,
    private val service: MeinMoersService
) : ViewModel() {

    fun load(): LiveData<Resource<List<Event>?>> {
        return eventRepository.getEvents()
    }

    fun loadOverview(): LiveData<Resource<EventOverviewUiState>> {
        return Transformations.map(service.getEventOverview()) { resource ->

            val upcomingEvents = resource.data?.data?.todayEvents.orEmpty()
                .map { EventUi(it) }

            val longTermEvents = resource.data?.data?.currentLongTermEvents.orEmpty()
                .map { EventUi(it) }

            Resource.success(EventOverviewUiState(upcomingEvents, longTermEvents))
        }
    }

}