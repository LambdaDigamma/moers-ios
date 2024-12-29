package com.lambdadigamma.radio.detail

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.map
import com.lambdadigamma.core.Resource
import com.lambdadigamma.radio.data.RadioBroadcastService
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class RadioBroadcastDetailViewModel @Inject constructor(
    private val radioBroadcastService: RadioBroadcastService
) : ViewModel() {

    var radioBroadcastId: Int? = null

    fun load(): LiveData<Resource<BroadcastDetailUiState>> {

        return if (radioBroadcastId != null) {
            return radioBroadcastService.show(radioBroadcastId!!).map { resource ->
                return@map resource.transform { dataResponse ->
                    BroadcastDetailUiState(
                        title = dataResponse.data.title,
                        description = dataResponse.data.description,
                        startsAt = dataResponse.data.startsAt,
                        endsAt = dataResponse.data.endsAt,
                        imageUrl = dataResponse.data.attach
                    )
                }
            }
        } else {
            MutableLiveData(Resource.loading())
        }

    }


}