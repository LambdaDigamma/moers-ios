package com.lambdadigamma.pages.data.remote.api

import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.JsonNull
import com.google.gson.JsonObject
import com.google.gson.JsonParseException
import com.google.gson.JsonSerializationContext
import com.google.gson.JsonSerializer
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.pages.data.mapper.BlockDataMapper
import com.lambdadigamma.pages.data.remote.ImageCollectionBlock
import com.lambdadigamma.pages.data.remote.TextBlock
import com.lambdadigamma.pages.data.remote.UnknownBlock
import com.lambdadigamma.pages.data.remote.model.BlockType
import com.lambdadigamma.pages.data.remote.model.PageBlock
import java.lang.reflect.Type
import java.util.Date

class PageBlockDeserializer: JsonDeserializer<PageBlock>, JsonSerializer<PageBlock> {

    override fun deserialize(
        json: JsonElement?,
        typeOfT: Type?,
        context: JsonDeserializationContext?
    ): PageBlock {

        val jsonObject = json?.asJsonObject ?: throw JsonParseException("Invalid JSON")

        val id = jsonObject.get("id")?.asInt ?: throw JsonParseException("Missing page id")
        val pageId = jsonObject.get("page_id")?.asInt
        val order = jsonObject.get("order")?.asInt ?: 0
        val typeString = jsonObject.get("type")?.asString ?: throw JsonParseException("Missing block type")
        val blockType = BlockDataMapper.getBlockType(typeString)

        val mediaCollectionsContainer = context?.
            deserialize<MediaCollectionsContainer>(
                jsonObject.get("media_collections"),
                MediaCollectionsContainer::class.java
            )

        val children = jsonObject
            .getAsJsonArray("children")
            .mapNotNull { child ->
                context?.deserialize<PageBlock>(child, PageBlock::class.java)
            }

        val data = when (blockType) {
            BlockType.Text -> context?.deserialize<TextBlock>(
                jsonObject.get("data"),
                TextBlock::class.java
            )
            BlockType.ImageCollection -> context?.deserialize<ImageCollectionBlock>(
                jsonObject.get("data"),
                ImageCollectionBlock::class.java
            )
            else -> UnknownBlock()
        } ?: throw JsonParseException("Unknown block type: $typeString")

        return PageBlock(
            id = id,
            pageID = pageId,
            type = typeString,
            data = data,
            children = children,
            order = order,
            mediaCollections = mediaCollectionsContainer,
            createdAt = context?.deserialize(jsonObject.get("created_at"), Date::class.java),
            updatedAt = context?.deserialize(jsonObject.get("updated_at"), Date::class.java),
            blockType = blockType
        )

    }

    override fun serialize(
        src: PageBlock?,
        typeOfSrc: Type?,
        context: JsonSerializationContext?
    ): JsonElement {

        if (src == null) {
            return JsonNull.INSTANCE
        }

        val jsonObject = JsonObject()
        jsonObject.addProperty("id", src.id)
        jsonObject.addProperty("page_id", src.pageID)
        jsonObject.addProperty("type", src.type)
        jsonObject.addProperty("blockType", src.blockType.type)
        jsonObject.add("data", context?.serialize(src.data))
        jsonObject.add("children", context?.serialize(src.children))
        jsonObject.add(
            "media_collections",
            context?.serialize(src.mediaCollections)
        )
        jsonObject.add("created_at", context?.serialize(src.createdAt))
        jsonObject.add("updated_at", context?.serialize(src.updatedAt))
        return jsonObject
    }

}