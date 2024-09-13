package com.lambdadigamma.core

import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class AppExecutors(
    val diskIO: Executor,
    val networkIO: Executor,
    val mainThread: Executor
) {

    constructor() : this(
        Executors.newSingleThreadExecutor(),
        Executors.newFixedThreadPool(3),
        MainThreadExecutor()
    )

    private class MainThreadExecutor : Executor {
        private val mainThreadHandler = Handler(Looper.getMainLooper())
        
        override fun execute(command: Runnable) {
            mainThreadHandler.post(command)
        }
    }
}
