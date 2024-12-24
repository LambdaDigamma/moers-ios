package app.moers.core.media

import androidx.annotation.DrawableRes


data class LocalMedia(
    @DrawableRes val resId: Int,
    val contentDescription: String? = null
) : MediaImageDisplayable {

    override fun data(width: Int, height: Int): Any {
        return resId
    }

    override fun contentDescription(): String? {
        return contentDescription
    }

}