package com.lambdadigamma.rubbish.notifications

import android.content.Context
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.graphics.drawable.toBitmap
import androidx.work.Data
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.lambdadigamma.rubbish.R
import com.lambdadigamma.rubbish.RubbishWasteType
import com.lambdadigamma.rubbish.icon
import com.lambdadigamma.rubbish.localizedName
import kotlin.random.Random

/**
 * A worker which sends a rubbish notification based on input data to the user.
 */
class RubbishScheduleNotificationWorker(
    val context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    override fun doWork(): Result {

        return try {

            val rubbishTypeValue = inputData.getString(WORKER_DATA_RUBBISH_TYPE_KEY)
            if (rubbishTypeValue == null) {
                Result.failure()
            }

            rubbishTypeValue?.let { value ->
                val rubbishWasteType = RubbishWasteType.fromString(value)

                val builder = NotificationCompat.Builder(context, CHANNEL_ID).apply {
                    setContentTitle(context.getString(R.string.rubbish_notification_title))
                    setContentText(
                        String.format(
                            context.getString(R.string.notification_rubbish_content),
                            rubbishWasteType.localizedName()
                        )
                    )
                    setGroup(GROUP_ID)
                    setAutoCancel(true)

                    AppCompatResources.getDrawable(context, rubbishWasteType.icon())?.let {
                        setSmallIcon(rubbishWasteType.icon())
                        setLargeIcon(it.toBitmap())
                    }

                }

                with(NotificationManagerCompat.from(context)) {
                    notify(Random.nextInt(), builder.build())
                }
            }

            Result.success()
        } catch (e: Exception) {
            Result.failure()
        }
    }

    companion object {

        fun inputData(rubbishType: RubbishWasteType): Data {
            return Data.Builder()
                .putString(WORKER_DATA_RUBBISH_TYPE_KEY, rubbishType.value)
                .build()
        }

        const val TAG = "rubbish_schedule_notification"
        const val CHANNEL_ID = "rubbish-schedule"
        const val GROUP_ID = "rubbish-schedule"

        const val WORKER_DATA_RUBBISH_TYPE_KEY = "rubbishType"

    }

}