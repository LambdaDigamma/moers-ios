package com.lambdadigamma.core

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform