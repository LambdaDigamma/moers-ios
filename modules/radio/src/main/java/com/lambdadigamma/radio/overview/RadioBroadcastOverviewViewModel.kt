package com.lambdadigamma.radio.overview

import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.lambdadigamma.core.Resource
import com.lambdadigamma.radio.data.RadioBroadcastService
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class RadioBroadcastOverviewViewModel @Inject constructor(
    private val radioBroadcastService: RadioBroadcastService
) : ViewModel() {

    fun load(): LiveData<Resource<List<RadioBroadcastListUiState>>> {
        return Transformations.map(radioBroadcastService.getUpcomingBroadcasts()) { resource ->
            return@map resource.transform { response ->
                response.data.map { radioBroadcast ->
                    RadioBroadcastListUiState(
                        id = radioBroadcast.id,
                        title = radioBroadcast.title,
                        startsAt = radioBroadcast.startsAt,
                        endsAt = radioBroadcast.endsAt,
                        imageUrl = radioBroadcast.attach,
                    )
                }
            }
        }
    }

}