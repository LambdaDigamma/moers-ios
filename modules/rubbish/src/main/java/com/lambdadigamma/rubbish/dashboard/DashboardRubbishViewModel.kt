package com.lambdadigamma.rubbish.dashboard

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lambdadigamma.core.Resource
import com.lambdadigamma.rubbish.RubbishCollectionItem
import com.lambdadigamma.rubbish.RubbishRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class DashboardRubbishViewModel @Inject constructor(
    private val rubbishRepository: RubbishRepository
) : ViewModel() {

    private val _rubbishCollectionItems = MutableLiveData<Resource<List<RubbishCollectionItem>>>()
    val rubbishCollectionItems: LiveData<Resource<List<RubbishCollectionItem>>> get() = _rubbishCollectionItems

    fun list() = viewModelScope.launch {
        rubbishRepository.loadRubbishCollectionItemsSuspended()
            .collect {
                _rubbishCollectionItems.value = it
            }
    }

}