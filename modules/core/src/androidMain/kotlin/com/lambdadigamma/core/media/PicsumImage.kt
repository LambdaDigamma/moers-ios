package com.lambdadigamma.core.media

data class PicsumMedia(val contentDescription: String? = null) : MediaImageDisplayable {

    override fun data(width: Int, height: Int): Any {
        return "https://picsum.photos/$width/$height"
    }

    override fun contentDescription(): String? {
        return null
    }

}

