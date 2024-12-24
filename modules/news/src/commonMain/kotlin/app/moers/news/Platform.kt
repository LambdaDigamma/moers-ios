package app.moers.news

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform