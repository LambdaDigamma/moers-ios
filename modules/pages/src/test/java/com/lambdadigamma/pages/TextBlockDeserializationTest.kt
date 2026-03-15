package com.lambdadigamma.pages

import com.google.gson.GsonBuilder
import com.lambdadigamma.pages.data.remote.TextBlock
import com.lambdadigamma.pages.data.remote.api.registerPageBlockTypeAdapter
import com.lambdadigamma.pages.data.remote.model.BlockType
import com.lambdadigamma.pages.data.remote.model.PageBlock
import com.lambdadigamma.prosemirror.Document
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import org.junit.jupiter.api.Test
import java.util.Date
import kotlin.test.assertEquals

class TextBlockDeserializationTest {

    @Test
    fun deserialize() {

        val givenJson = """
        {
            "id": 978,
            "page_id": 405,
            "type": "tip-tap-text-with-media",
            "data": {
              "title": null,
              "text": {
                "type": "doc",
                "content": [
                  {
                    "type": "paragraph",
                    "content": [
                      {
                        "type": "text",
                        "text": "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix \u00a0und einem Soloset zur\u00fcck nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!"
                      }
                    ]
                  }
                ]
              }
            },
            "parent_id": null,
            "slot": null,
            "order": 1,
            "created_at": "2023-04-27T22:13:23.000000Z",
            "updated_at": "2023-05-04T18:06:03.000000Z",
            "published_at": "2023-04-27T22:13:23.000000Z",
            "expired_at": null,
            "hidden_at": null,
            "deleted_at": null,
            "children": [],
            "media_collections": [],
            "slots": []
          }
        """.trimIndent()

        val gson = GsonBuilder()
            .registerPageBlockTypeAdapter()
            .create()

        val pageBlock = gson.fromJson(givenJson, PageBlock::class.java)

        assertEquals(978, pageBlock.id)
        assertEquals(405, pageBlock.pageID)
        assertEquals("tip-tap-text-with-media", pageBlock.type)
        assertEquals(BlockType.Text, pageBlock.blockType)
        assertEquals(0, pageBlock.children.size)
        assertEquals(0, pageBlock.mediaCollections?.collections?.size)
        assertEquals("Fri Apr 28 00:13:23 CEST 2023", pageBlock.createdAt?.toString())
        assertEquals("Thu May 04 20:06:03 CEST 2023", pageBlock.updatedAt?.toString())

    }

    @Test
    fun serialize() {

        val givenPageBlock = PageBlock(
            id = 978,
            pageID = 405,
            type = "tip-tap-text-with-media",
            data = TextBlock(
                title = "Hallo",
                subtitle = null,
                text = Document(
                    content = listOf(
                        NodeParagraph(
                            content = listOf(
                                NodeText(text = "Hallo")
                            )
                        )
                    )
                )
            ),
            children = emptyList(),
            mediaCollections = null,
            createdAt = Date(1684452770139),
            updatedAt = Date(1684452770139),
            blockType = BlockType.Text
        )

        val gson = GsonBuilder()
            .registerPageBlockTypeAdapter()
            .create()

        val json = gson.toJson(givenPageBlock)

        assertEquals("""
            {"id":978,"page_id":405,"type":"tip-tap-text-with-media","blockType":"tip-tap-text-with-media","data":{"title":"Hallo","text":{"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Hallo","marks":[]}]}]}},"children":[],"created_at":"May 19, 2023, 1:32:50 AM","updated_at":"May 19, 2023, 1:32:50 AM"}
        """.trimIndent(), json)

    }

}