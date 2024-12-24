package app.moers.core.utils

import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.math.abs

fun Date.minuteInterval(): Int {

    val now = Date()
    val diffInMillis = abs(this.time - now.time)
    var diff = TimeUnit.MINUTES.convert(diffInMillis, TimeUnit.MILLISECONDS)

    if (diff == 0L) {
        diff = 1L
    }

    return diff.toInt()

}