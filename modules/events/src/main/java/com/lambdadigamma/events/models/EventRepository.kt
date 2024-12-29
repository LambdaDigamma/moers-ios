package com.lambdadigamma.events.models

import android.content.Context
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.map
import com.lambdadigamma.core.*
import com.lambdadigamma.core.utils.LastUpdate
import com.lambdadigamma.core.utils.minuteInterval
import dagger.hilt.android.qualifiers.ApplicationContext
import java.util.*
import javax.inject.Inject

class EventRepository @Inject constructor(
    @ApplicationContext context: Context,
    private val eventDao: EventDao,
    private val moersService: MeinMoersService,
    private val appExecutors: AppExecutors
) {

    private val lastUpdate = LastUpdate("events", context)

    fun getEvents(): LiveData<Resource<List<Event>?>> {
        return object : NetworkBoundResource<List<Event>, List<Event>>(appExecutors) {

            override fun saveCallResult(item: List<Event>) {
                lastUpdate.set(Date())
                eventDao.insertEvents(item)
            }

            override fun shouldFetch(data: List<Event>?): Boolean {
                return data == null ||
                        data.orEmpty().isEmpty() ||
                        (lastUpdate.get()?.minuteInterval() ?: 120) > 60
            }

            override fun loadFromDb() =
                eventDao.getEvents().map { events -> events.sortedBy { it.startDate } }

            override fun createCall(): LiveData<Resource<List<Event>>> {
                return moersService.getEvents().map { resource ->
                    return@map resource.transform { response ->
                        return@transform response.data.sortedBy { it.startDate }
                    }
                }
            }

        }.asLiveData()
    }

    fun getEvent(id: Int): LiveData<Resource<Event?>> {
        return object : NetworkBoundResource<Event, Event>(appExecutors) {

            override fun saveCallResult(item: Event) {
                eventDao.insertEvents(listOf(item))
            }

            override fun shouldFetch(data: Event?): Boolean {
                return data == null
            }

            override fun loadFromDb() = eventDao.getEvent(id)

            override fun createCall(): LiveData<Resource<Event>> {
                return moersService.getEvent(id).map { resource ->
                    return@map resource.transform { response ->
                        return@transform response
                    }
                }
            }
        }.asLiveData()
    }

    fun getMockedEvents(): LiveData<Resource<List<Event>?>> {

        val events = listOf(
            Event(59, "Event 1", addingMinutes(-29), null),
            Event(60, "Event 2", addingMinutes(-1), addingMinutes(2)),
            Event(61, "Event 3", addingMinutes(1), null),
            Event(62, "Event 4", addingMinutes(20), null),
            Event(63, "Event 5", addingMinutes(65), null)
        )

        val resource = Resource<List<Event>?>(Status.SUCCESS, events)

        val data = MutableLiveData<Resource<List<Event>?>>()

        data.postValue(resource)

        return data

    }

}