package com.lambdadigamma.core.refresh

import java.net.ConnectException
import java.net.NoRouteToHostException
import java.net.SocketException
import java.net.SocketTimeoutException
import java.net.UnknownHostException

object RefreshFailureClassifier {

    fun classify(throwable: Throwable): RefreshFailureReason {
        val causes = throwable.causes()

        return when {
            causes.any { it is SocketTimeoutException } -> RefreshFailureReason.TIMEOUT
            causes.any(::isNoInternetFailure) -> RefreshFailureReason.NO_INTERNET
            else -> RefreshFailureReason.GENERIC
        }
    }

    private fun isNoInternetFailure(throwable: Throwable): Boolean {
        return throwable is UnknownHostException ||
            throwable is ConnectException ||
            throwable is NoRouteToHostException ||
            throwable.isNetworkUnreachableSocketException()
    }

    private fun Throwable.isNetworkUnreachableSocketException(): Boolean {
        if (this !is SocketException) {
            return false
        }

        val normalizedMessage = message?.lowercase().orEmpty()
        return NETWORK_UNREACHABLE_MESSAGES.any(normalizedMessage::contains)
    }

    private fun Throwable.causes(): List<Throwable> {
        val causes = mutableListOf<Throwable>()
        val seen = mutableSetOf<Throwable>()
        var current: Throwable? = this

        while (current != null && seen.add(current)) {
            causes += current
            current = current.cause
        }

        return causes
    }

    private val NETWORK_UNREACHABLE_MESSAGES = listOf(
        "network is unreachable",
        "no route to host",
        "no address associated with hostname",
    )
}
