package com.lambdadigamma.medialibrary

import com.google.gson.GsonBuilder
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
class MediaCollectionsContainerTest {
    @Test
    fun testEmptyCollectionArray() {

        val json = """
            []
        """.trimIndent()

        val container = GsonBuilder()
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerDeserializer())
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerSerializer())
            .create()
            .fromJson(json, MediaCollectionsContainer::class.java)

        assertEquals(0, container.collections.size)

    }

    @Test
    fun testEmptyCollectionObject() {

        val json = """
            {}
        """.trimIndent()

        val container = GsonBuilder()
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerDeserializer())
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerSerializer())
            .create()
            .fromJson(json, MediaCollectionsContainer::class.java)

        assertEquals(0, container.collections.size)

    }

    @Test
    fun testSerializeAndDeserialize() {

        val mediaCollection = MediaCollectionsContainer(
            collections = mapOf(
                "header" to listOf(
                    Media(
                        id = 1,
                        modelType = "posts",
                        modelId = 1,
                        uuid = "51F5406B-08EE-4517-AB1D-8ADFAF2D35F0",
                        collectionName = "header",
//                        fullURL = null,
                        name = "posts1.png",
                        fileName = "posts1.png",
                        fullUrl = null
//                        size = 1000,
//                        alt = null,
//                        caption = null,
                    )
                )
            )
        )

        val gson = GsonBuilder()
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerDeserializer())
            .registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerSerializer())
            .setPrettyPrinting()
            .create()
        val encoded = gson.toJson(mediaCollection)
        println("Encoded: $encoded")

        val decodedMediaCollection = gson.fromJson(encoded, MediaCollectionsContainer::class.java)
        println("Decoded: $decodedMediaCollection")

        assertEquals(mediaCollection, decodedMediaCollection)

    }
}