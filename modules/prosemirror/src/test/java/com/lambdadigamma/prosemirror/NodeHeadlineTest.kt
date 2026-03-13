package com.lambdadigamma.prosemirror

import com.lambdadigamma.prosemirror.nodes.HeadlineAttributes
import com.lambdadigamma.prosemirror.nodes.MarkType
import com.lambdadigamma.prosemirror.nodes.NodeHeadline
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import com.lambdadigamma.prosemirror.nodes.ParagraphAttributes
import com.lambdadigamma.prosemirror.nodes.TextAlignment
import org.junit.jupiter.api.Test

class NodeHeadlineTest: DefaultNodeProsemirrorTest() {

    @Test
    fun basicDecoding() {

        val jsonString = """
        {
            "type": "doc",
            "content": [
                {
                    "type": "headline",
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
                NodeHeadline(
                    content = listOf(
                        NodeText(
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
            content = listOf(
                NodeHeadline(
                    content = listOf(
                        NodeText(
                            text = "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!",
                        )
                    )
                )
            )
        )

        assertEncodeCorrect(
            encoding = givenDocument,
            expectedJson = """
                {"type":"doc","content":[{"type":"headline","content":[{"type":"text","text":"Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!","marks":[]}]}]}
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
                    "type": "headline",
                    "content": [
                        {
                            "type": "text",
                            "text": "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!"
                        }
                    ],
                    "attrs": {
                        "level": 1,
                        "textAlign": "center"
                    }
                }
            ]
        }
        """.trimIndent()

        val expectedDocument = Document(
            type = "doc",
            content = listOf(
                NodeHeadline(
                    content = listOf(
                        NodeText(
                            text = "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!",
                            marks = listOf()
                        )
                    ),
                    attributes = HeadlineAttributes(
                        textAlignment = TextAlignment.CENTER,
                        level = 1
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
            content = listOf(
                NodeHeadline(
                    content = listOf(
                        NodeText(
                            type = "text",
                            text = "Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!",
                        )
                    ),
                    attributes = HeadlineAttributes(
                        level = 2,
                        textAlignment = TextAlignment.RIGHT
                    )
                )
            )
        )

        assertEncodeCorrect(
            encoding = givenDocument,
            expectedJson = """
                {"type":"doc","content":[{"type":"headline","content":[{"type":"text","text":"Gitarrist:in Wendy Eisenberg kehrt nach their fulminanten Auftritt mit Strictly Missionary 2021 mit der Formation Editrix  und einem Soloset zurück nach Moers. Editrix sind ein erster Vorgeschmack auf das, was euch Pfingsten 2023 (auch) in Moers erwartet: Bands und Projects abseits aller Klischees, voller Energie, klug und mit Haltung. Lang lebe die Avantgarde!","marks":[]}],"attrs":{"level":2,"textAlign":"right"}}]}
            """.trimIndent().trimEnd()
        )

    }

}