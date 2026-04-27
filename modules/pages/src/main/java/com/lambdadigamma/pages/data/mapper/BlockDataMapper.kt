package com.lambdadigamma.pages.data.mapper

import com.google.gson.GsonBuilder
import com.lambdadigamma.pages.data.remote.ExternalLinkBlock
import com.lambdadigamma.pages.data.remote.ImageCollectionBlock
import com.lambdadigamma.pages.data.remote.LinkListBlock
import com.lambdadigamma.pages.data.remote.SoundcloudBlock
import com.lambdadigamma.pages.data.remote.TextBlock
import com.lambdadigamma.pages.data.remote.YoutubeVideoBlock
import com.lambdadigamma.pages.data.remote.api.registerPageBlockTypeAdapter
import com.lambdadigamma.pages.data.remote.model.BlockType
import com.lambdadigamma.pages.data.remote.model.SomeBlockData

class BlockDataMapper {

    companion object {

        private fun gson() = GsonBuilder()
            .registerPageBlockTypeAdapter()
            .create()

        fun getBlockType(type: String): BlockType {
            return when (type) {
                BlockType.YoutubeVideo.type -> BlockType.YoutubeVideo
                BlockType.Soundcloud.type -> BlockType.Soundcloud
                BlockType.ExternalLink.type -> BlockType.ExternalLink
                BlockType.Text.type -> BlockType.Text
                BlockType.LinkList.type -> BlockType.LinkList
                BlockType.ImageCollection.type -> BlockType.ImageCollection
                else -> BlockType.Unknown // throw IllegalArgumentException("Unknown block type: $type")
            }
        }

        fun toString(data: SomeBlockData, type: BlockType): String {
            val gson = gson()
            return gson.toJson(data)
        }

        fun fromString(data: String, type: BlockType): SomeBlockData {
            val gson = gson()

            return when (type) {
                BlockType.YoutubeVideo -> gson.fromJson(data, YoutubeVideoBlock::class.java)
                BlockType.Soundcloud -> gson.fromJson(data, SoundcloudBlock::class.java)
                BlockType.ExternalLink -> gson.fromJson(data, ExternalLinkBlock::class.java)
                BlockType.Text -> gson.fromJson(data, TextBlock::class.java)
                BlockType.LinkList -> gson.fromJson(data, LinkListBlock::class.java)
                BlockType.ImageCollection -> gson.fromJson(data, ImageCollectionBlock::class.java)
                else -> throw IllegalArgumentException("Unknown block type: $type")
            }
        }

    }

}
