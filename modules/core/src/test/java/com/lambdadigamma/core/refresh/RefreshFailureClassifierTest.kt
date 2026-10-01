package com.lambdadigamma.core.refresh

import org.junit.jupiter.api.Test
import java.io.IOException
import java.net.ConnectException
import java.net.SocketException
import java.net.SocketTimeoutException
import java.net.UnknownHostException
import kotlin.test.assertEquals

class RefreshFailureClassifierTest {

    @Test
    fun `classifies unknown host as no internet`() {
        assertEquals(
            RefreshFailureReason.NO_INTERNET,
            RefreshFailureClassifier.classify(UnknownHostException()),
        )
    }

    @Test
    fun `classifies connect failure as no internet`() {
        assertEquals(
            RefreshFailureReason.NO_INTERNET,
            RefreshFailureClassifier.classify(ConnectException()),
        )
    }

    @Test
    fun `classifies network unreachable socket failure as no internet`() {
        assertEquals(
            RefreshFailureReason.NO_INTERNET,
            RefreshFailureClassifier.classify(SocketException("Network is unreachable")),
        )
    }

    @Test
    fun `classifies timeout before generic socket failure`() {
        assertEquals(
            RefreshFailureReason.TIMEOUT,
            RefreshFailureClassifier.classify(SocketTimeoutException()),
        )
    }

    @Test
    fun `classifies nested no internet cause`() {
        assertEquals(
            RefreshFailureReason.NO_INTERNET,
            RefreshFailureClassifier.classify(IOException("Refresh failed", UnknownHostException())),
        )
    }

    @Test
    fun `classifies unknown failure as generic`() {
        assertEquals(
            RefreshFailureReason.GENERIC,
            RefreshFailureClassifier.classify(IllegalStateException("Parser failed")),
        )
    }
}
