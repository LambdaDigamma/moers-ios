package com.lambdadigamma.news

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform