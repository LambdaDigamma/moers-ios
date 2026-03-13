package com.lambdadigamma.moers.misc

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import com.google.android.play.core.review.ReviewManagerFactory
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

@HiltViewModel
class FeedbackViewModel @Inject constructor(@ApplicationContext context: Context) : ViewModel() {

    private val manager = ReviewManagerFactory.create(context)

    fun startReview(activity: Activity) {
        Log.i("FeedbackViewModel", "Starting review")
        val request = manager.requestReviewFlow()
        request.addOnCompleteListener { task ->
            if (task.isSuccessful) {

                val reviewInfo = task.result
                val flow = manager.launchReviewFlow(activity, reviewInfo)

                flow.addOnCompleteListener { _ ->
                    // The flow has finished. The API does not indicate whether the user
                    // reviewed or not, or even whether the review dialog was shown. Thus, no
                    // matter the result, we continue our app flow.
                }

            }
        }
    }

}