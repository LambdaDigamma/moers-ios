package com.lambdadigamma.pages

import com.google.gson.GsonBuilder
import com.lambdadigamma.pages.data.remote.TextBlock
import com.lambdadigamma.pages.data.remote.api.registerPageBlockTypeAdapter
import com.lambdadigamma.pages.data.remote.model.BlockType
import com.lambdadigamma.pages.data.remote.model.PageBlock
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs

class PageBlockChildrenDeserializationTest {

    @Test
    fun `deserialize nested child blocks`() {
        val givenJson = """
            {
              "id": 100,
              "page_id": 12,
              "type": "tip-tap-text-with-media",
              "data": {
                "title": "Parent",
                "subtitle": "Subtitle",
                "text": {
                  "type": "doc",
                  "content": [
                    {
                      "type": "paragraph",
                      "content": [
                        {
                          "type": "text",
                          "text": "Parent text"
                        }
                      ]
                    }
                  ]
                }
              },
              "order": 1,
              "children": [
                {
                  "id": 101,
                  "page_id": 12,
                  "type": "tip-tap-text-with-media",
                  "data": {
                    "title": "Child",
                    "text": {
                      "type": "doc",
                      "content": [
                        {
                          "type": "paragraph",
                          "content": [
                            {
                              "type": "text",
                              "text": "Child text"
                            }
                          ]
                        }
                      ]
                    }
                  },
                  "order": 2,
                  "children": [],
                  "media_collections": [],
                  "created_at": "2023-04-27T22:13:23.000000Z",
                  "updated_at": "2023-05-04T18:06:03.000000Z"
                }
              ],
              "media_collections": [],
              "created_at": "2023-04-27T22:13:23.000000Z",
              "updated_at": "2023-05-04T18:06:03.000000Z"
            }
        """.trimIndent()

        val gson = GsonBuilder()
            .registerPageBlockTypeAdapter()
            .create()

        val pageBlock = gson.fromJson(givenJson, PageBlock::class.java)

        assertEquals(BlockType.Text, pageBlock.blockType)
        assertEquals(1, pageBlock.children.size)

        val child = pageBlock.children.single()
        assertEquals(101, child.id)
        assertEquals(BlockType.Text, child.blockType)
        assertIs<TextBlock>(child.data)
        assertEquals("Child", (child.data as TextBlock).title)
    }
}
