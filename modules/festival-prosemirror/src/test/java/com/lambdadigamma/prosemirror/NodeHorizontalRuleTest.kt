package com.lambdadigamma.prosemirror

import com.lambdadigamma.prosemirror.nodes.NodeHardBreak
import com.lambdadigamma.prosemirror.nodes.NodeHorizontalRule
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import org.junit.jupiter.api.Test
import kotlin.math.exp

class NodeHorizontalRuleTest: DefaultNodeProsemirrorTest() {

    @Test
    fun decode() {

        val givenJson = """
        {
            "type": "doc",
            "content": [
                {
                    "type": "paragraph",
                    "content": [
                        {
                            "text": "Pünktlich zu unserem 50-jährigem Jubiläum ziehen wir mit dem Hauptteil des Marktes zurück in den Schlosspark und erfüllen uns und vielen langjährigen Festivalbesuchern damit einen sehnlichen Wunsch.",
                            "type": "text"
                        }
                    ]
                },
                {
                    "type": "horizontalRule"
                }
            ]
        }
        """.trimIndent()

        assertDecodeCorrect(
            json = givenJson,
            expectedDocument = Document(content = listOf(
                NodeParagraph(content = listOf(
                    NodeText(text = "Pünktlich zu unserem 50-jährigem Jubiläum ziehen wir mit dem Hauptteil des Marktes zurück in den Schlosspark und erfüllen uns und vielen langjährigen Festivalbesuchern damit einen sehnlichen Wunsch.")
                )),
                NodeHorizontalRule()
            ))
        )

    }

    @Test
    fun encode() {

        val givenDocument = Document(content = listOf(
            NodeParagraph(content = listOf(
                NodeText(text = "Pünktlich zu unserem 50-jährigem Jubiläum ziehen wir mit dem Hauptteil des Marktes zurück in den Schlosspark und erfüllen uns und vielen langjährigen Festivalbesuchern damit einen sehnlichen Wunsch.")
            )),
            NodeHorizontalRule()
        ))

        assertEncodeCorrect(
            encoding = givenDocument,
            expectedJson = """
            {"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Pünktlich zu unserem 50-jährigem Jubiläum ziehen wir mit dem Hauptteil des Marktes zurück in den Schlosspark und erfüllen uns und vielen langjährigen Festivalbesuchern damit einen sehnlichen Wunsch.","marks":[]}]},{"type":"horizontalRule"}]}
            """.trimIndent()
        )

    }

}