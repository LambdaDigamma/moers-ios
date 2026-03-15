package com.lambdadigamma.pages.data.remote.model

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonDeserializer
import com.google.gson.annotations.SerializedName
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import java.text.SimpleDateFormat
import java.util.*

data class Page(
    @SerializedName("id") val id: Int,
    @SerializedName("title") var title: String? = null,
    @SerializedName("summary") var summary: String? = null,
    @SerializedName("page_template_id") var pageTemplateID: Int? = null,
    @SerializedName("slug") var slug: String? = null,
    @SerializedName("blocks") var blocks: List<PageBlock> = emptyList(),
    @SerializedName("resource_url") var resourceUrl: String? = null,
    @SerializedName("creator_id") var creatorID: Int? = null,
//    @SerializedName("extras") var extras: Map<String, String>? = null,
    @SerializedName("media_collections") var mediaCollections: MediaCollectionsContainer  = MediaCollectionsContainer(),
    @SerializedName("archived_at") var archivedAt: Date? = null,
    @SerializedName("created_at") var createdAt: Date? = Date(),
    @SerializedName("updated_at") var updatedAt: Date? = Date()
) {


    companion object {
        fun stub(id: Int): Page {
            return Page(
                id = id,
                title = "",
                mediaCollections = MediaCollectionsContainer()
            )
        }

        val decoder: Gson
            get() {
                val builder = GsonBuilder()
                val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z")
                formatter.timeZone = TimeZone.getTimeZone("UTC")
                builder.setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z")
                builder.registerTypeAdapter(Date::class.java, JsonDeserializer { json, _, _ ->
                    val dateString = json.asString
                    formatter.parse(dateString)
                })
                return builder.create()
            }
    }
}