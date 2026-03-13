package com.lambdadigamma.prosemirror

import com.lambdadigamma.prosemirror.nodes.NodeBlockquote
import com.lambdadigamma.prosemirror.nodes.NodeBulletList
import com.lambdadigamma.prosemirror.nodes.NodeOrderedList
import com.lambdadigamma.prosemirror.nodes.NodeText
import org.junit.jupiter.api.Test

class NodeOrderedListTest: DefaultNodeProsemirrorTest() {

    @Test
    fun decode() {

        val givenJson = """
        {
            "type": "doc",
            "content": [
                {
                    "type": "orderedList",
                    "content": [
                        {
                            "text": "Just testing",
                            "type": "text"
                        }
                    ]
                }
            ]
        }
        """.trimIndent()

        assertDecodeCorrect(
            json = givenJson,
            expectedDocument = Document(content = listOf(
                NodeOrderedList(content = listOf(
                    NodeText(text = "Just testing")
                ))
            ))
        )

    }

    @Test
    fun encode() {

        val givenDocument = Document(content = listOf(
            NodeOrderedList(content = listOf(
                NodeText(text = "Testing.")
            )),
        ))

        assertEncodeCorrect(
            encoding = givenDocument,
            expectedJson = """
            {"type":"doc","content":[{"type":"orderedList","content":[{"type":"text","text":"Testing.","marks":[]}]}]}
            """.trimIndent()
        )

    }


}