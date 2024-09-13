package com.lambdadigamma.core

import LiveDataCallAdapter
import Resource
import androidx.lifecycle.LiveData
import retrofit2.CallAdapter
import retrofit2.Retrofit
import java.lang.IllegalArgumentException
import java.lang.reflect.ParameterizedType
import java.lang.reflect.Type

class LiveDataCallAdapterFactory : CallAdapter.Factory() {

    override fun get(
        returnType: Type,
        annotations: Array<Annotation>,
        retrofit: Retrofit
    ): CallAdapter<*, *>? {
        // Check if the return type is LiveData
        if (getRawType(returnType) != LiveData::class.java) {
            return null
        }

        // Ensure returnType is parameterized
        if (returnType !is ParameterizedType) {
            throw IllegalArgumentException("LiveData must be parameterized")
        }

        // Get the type inside LiveData<...>
        val observableType = getParameterUpperBound(0, returnType)
        val rawObservableType = getRawType(observableType)

        // Check if the type inside LiveData is Resource
        if (rawObservableType != Resource::class.java) {
            throw IllegalArgumentException("type must be a Resource")
        }

        // Ensure Resource is parameterized
        if (observableType !is ParameterizedType) {
            throw IllegalArgumentException("Resource must be parameterized")
        }

        // Get the type inside Resource<...>
        val bodyType = getParameterUpperBound(0, observableType)
        return LiveDataCallAdapter<Any>(bodyType)
    }
}
