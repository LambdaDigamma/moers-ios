package com.lambdadigamma.core.refresh

enum class RefreshMetadataKey(
    val preferenceName: String,
) {
    TIMETABLE("festival_timetable_last_successful_refresh_epoch_millis"),
    NEWS("festival_news_last_successful_refresh_epoch_millis"),
}
