package app.moers.core

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform