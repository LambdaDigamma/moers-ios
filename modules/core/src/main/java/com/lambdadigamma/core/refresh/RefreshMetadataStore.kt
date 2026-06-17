package com.lambdadigamma.core.refresh

import java.util.Date

interface RefreshMetadataStore {
    suspend fun getLastSuccessfulRefresh(key: RefreshMetadataKey): Date?

    suspend fun markSuccessfulRefresh(key: RefreshMetadataKey)
}
