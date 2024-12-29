package com.lambdadigamma.rubbish

import android.content.Context
import android.util.Log
import androidx.lifecycle.*
import com.lambdadigamma.core.Resource
import com.lambdadigamma.rubbish.settings.RubbishSettings
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class RubbishScheduleViewModel @Inject constructor(
    private val rubbishRepository: RubbishRepository,
    @ApplicationContext val context: Context
) : ViewModel() {

    private val _rubbishCollectionItems = MutableLiveData<Resource<List<RubbishCollectionItem>>>()
    val rubbishCollectionItems: LiveData<Resource<List<RubbishCollectionItem>>> get() = _rubbishCollectionItems

    var rubbishSchedule: MutableLiveData<Resource<List<RubbishCollectionItem>?>> =
        MutableLiveData(Resource.loading())

    var rubbishCollectionStreet: LiveData<Resource<RubbishSettings.RubbishCollectionStreet>> =
        MutableLiveData(Resource.loading())

//    private var rubbishRepository: RubbishRepository = RubbishRepository(
//        remoteDataSource = RubbishRemoteDataSource(
//            rubbishApi = DefaultRubbishApiService.getRubbishService(),
//            ioDispatcher = Dispatchers.IO
//        ),
//        remote
//        rubbishDao = rubbishDao,
//        context = context
//    )

    suspend fun load() {
        Log.d("UI", "Loading rubbish collection items")

        rubbishCollectionStreet = rubbishRepository
            .currentStreet
            .map { Resource.success(it) }
            .asLiveData()

        viewModelScope.launch {
            rubbishRepository.loadRubbishCollectionItemsSuspended()
                .collect {
                    _rubbishCollectionItems.value = it
                }
        }


//        rubbishRepository.loadRubbishCollectionItems()
//            .observeForever {
//                rubbishSchedule.postValue(Resource.success(it.data.orEmpty()))
//            }


//        rubbishSchedule =
//            Transformations.map(rubbishRepository.remoteDataSource.getPickupItems(1)) {
//                Log.d("UI", "Received rubbish collection items")
//                return@map Resource.success(it.data?.data.orEmpty())
//            }

//        rubbishSchedule = rubbishRepository.loadRubbishCollectionItems()
//        news = newsRepository.getNews()
//
//        rubbishSchedule.rubbishSchedule = MutableLiveData(
//            Resource.success(rubbishRepository.loadRubbishCollectionItems())
//        )
    }

}
