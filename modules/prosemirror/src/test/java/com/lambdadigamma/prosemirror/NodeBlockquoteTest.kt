package com.lambdadigamma.prosemirror

import com.lambdadigamma.prosemirror.nodes.NodeBlockquote
import com.lambdadigamma.prosemirror.nodes.NodeHardBreak
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import org.junit.jupiter.api.Test
import kotlin.math.exp

class NodeBlockquoteTest: DefaultNodeProsemirrorTest() {

    @Test
    fun decode() {

        val givenJson = """
        {
            "type": "doc",
            "content": [
                {
                    "type": "blockquote",
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
                NodeBlockquote(content = listOf(
                    NodeText(text = "Just testing")
                ))
            ))
        )

    }

    @Test
    fun encode() {

        val givenDocument = Document(content = listOf(
            NodeBlockquote(content = listOf(
                NodeText(text = "Testing.")
            )),
        ))

        assertEncodeCorrect(
            encoding = givenDocument,
            expectedJson = """
            {"type":"doc","content":[{"type":"blockquote","content":[{"type":"text","text":"Testing.","marks":[]}]}]}
            """.trimIndent()
        )

    }

}