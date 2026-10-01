package com.lambdadigamma.core.refresh

import java.util.Date

class FakeRefreshMetadataStore(
    private val lastSuccessfulRefresh: MutableMap<RefreshMetadataKey, Date?> = mutableMapOf(),
    private val readFailure: Throwable? = null,
    private val writeFailure: Throwable? = null,
) : RefreshMetadataStore {

    val markedKeys = mutableListOf<RefreshMetadataKey>()

    override suspend fun getLastSuccessfulRefresh(key: RefreshMetadataKey): Date? {
        readFailure?.let { throw it }
        return lastSuccessfulRefresh[key]
    }

    override suspend fun markSuccessfulRefresh(key: RefreshMetadataKey) {
        writeFailure?.let { throw it }
        markedKeys += key
        lastSuccessfulRefresh[key] = Date()
    }

    fun setLastSuccessfulRefresh(key: RefreshMetadataKey, date: Date?) {
        lastSuccessfulRefresh[key] = date
    }
}
