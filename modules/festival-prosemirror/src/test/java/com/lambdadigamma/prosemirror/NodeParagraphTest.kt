package com.lambdadigamma.prosemirror

import com.lambdadigamma.prosemirror.nodes.MarkType
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import com.lambdadigamma.prosemirror.nodes.ParagraphAttributes
import com.lambdadigamma.prosemirror.nodes.TextAlignment
import org.junit.jupiter.api.Test

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
class NodeParagraphTest: DefaultNodeProsemirrorTest() {

    @Test
    fun basicDecoding() {

        val jsonString = """
        {
            "type": "doc",
            "content": [
                {
                    "type": "paragraph",
                    "content": [
                        {
                            "type": "text",
                            "text": "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!"
                        }
                    ]
                }
            ]
        }
        """.trimIndent()

        val expectedDocument = Document(
            type = "doc",
            content = listOf(
                NodeParagraph(
                    type = "paragraph",
                    content = listOf(
                        NodeText(
                            type = "text",
                            text = "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!",
                            marks = listOf()
                        )
                    )
                )
            )
        )

        assertDecodeCorrect(
            json = jsonString,
            expectedDocument = expectedDocument
        )

    }

    @Test
    fun basicEncoding() {

        val givenDocument = Document(
            type = "doc",
            content = listOf(
                NodeParagraph(
                    type = "paragraph",
                    content = listOf(
                        NodeText(
                            type = "text",
                            text = "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!",
                            marks = listOf(
                                MarkType.Bold,
                                MarkType.Italic
                            )
                        )
                    )
                )
            )
        )

        assertEncodeCorrect(
            encoding = givenDocument,
            expectedJson = """
                {"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!","marks":[{"type":"bold"},{"type":"italic"}]}]}]}           
            """.trimIndent().trimEnd()
        )

    }

    @Test
    fun decodingWithAttributes() {

        val jsonString = """
        {
            "type": "doc",
            "content": [
                {
                    "type": "paragraph",
                    "content": [
                        {
                            "type": "text",
                            "text": "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!"
                        }
                    ],
                    "attrs": {
                        "textAlign": "center"
                    }
                }
            ]
        }
        """.trimIndent()

        val expectedDocument = Document(
            type = "doc",
            content = listOf(
                NodeParagraph(
                    type = "paragraph",
                    content = listOf(
                        NodeText(
                            type = "text",
                            text = "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!",
                            marks = listOf()
                        )
                    ),
                    attributes = ParagraphAttributes(
                        textAlignment = TextAlignment.CENTER
                    )
                )
            )
        )

        assertDecodeCorrect(
            json = jsonString,
            expectedDocument = expectedDocument
        )

    }

    @Test
    fun encodeWithAttributes() {

        val givenDocument = Document(
            type = "doc",
            content = listOf(
                NodeParagraph(
                    type = "paragraph",
                    content = listOf(
                        NodeText(
                            type = "text",
                            text = "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!",
                            marks = listOf()
                        )
                    ),
                    attributes = ParagraphAttributes(
                        textAlignment = TextAlignment.CENTER
                    )
                )
            )
        )

        assertEncodeCorrect(
            encoding = givenDocument,
            expectedJson = """
                {"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!","marks":[]}],"attrs":{"textAlign":"center"}}]}           
            """.trimIndent().trimEnd()
        )

    }

}