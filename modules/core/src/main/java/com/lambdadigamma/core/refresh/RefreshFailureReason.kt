package com.lambdadigamma.core.refresh

import androidx.annotation.StringRes
import com.lambdadigamma.core.R

enum class RefreshFailureReason(
    @param:StringRes val messageResId: Int,
    @param:StringRes val messageWithLastUpdateResId: Int,
) {
    NO_INTERNET(
        messageResId = R.string.refresh_failure_no_internet,
        messageWithLastUpdateResId = R.string.refresh_failure_no_internet_with_last_update,
    ),
    TIMEOUT(
        messageResId = R.string.refresh_failure_timeout,
        messageWithLastUpdateResId = R.string.refresh_failure_timeout_with_last_update,
    ),
    GENERIC(
        messageResId = R.string.refresh_failure_generic,
        messageWithLastUpdateResId = R.string.refresh_failure_generic_with_last_update,
    ),
}
