package com.lambdadigamma.prosemirror.serialization

import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.lambdadigamma.prosemirror.Document
import com.lambdadigamma.prosemirror.nodes.HeadlineAttributes
import com.lambdadigamma.prosemirror.nodes.MarkLinkAttributes
import com.lambdadigamma.prosemirror.nodes.MarkType
import com.lambdadigamma.prosemirror.nodes.NodeBlockquote
import com.lambdadigamma.prosemirror.nodes.NodeBulletList
import com.lambdadigamma.prosemirror.nodes.NodeHardBreak
import com.lambdadigamma.prosemirror.nodes.NodeHeadline
import com.lambdadigamma.prosemirror.nodes.NodeHorizontalRule
import com.lambdadigamma.prosemirror.nodes.NodeListItem
import com.lambdadigamma.prosemirror.nodes.NodeOrderedList
import com.lambdadigamma.prosemirror.nodes.ProsemirrorNode
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import com.lambdadigamma.prosemirror.nodes.ParagraphAttributes
import java.lang.reflect.Type

class DocumentDeserializer: JsonDeserializer<Document> {

    override fun deserialize(
        json: JsonElement?,
        typeOfT: Type?,
        context: JsonDeserializationContext?
    ): Document {

        if (json == null) return Document(Document.type)

        val documentObject = json.asJsonObject
        val document = Document(Document.type)

        if (documentObject.get("type").asString != Document.type) return document

        val topLevelNodes = documentObject.get("content").asJsonArray.asList()

        document.content = topLevelNodes.mapNotNull { node ->
            val nodeObject = node.asJsonObject
            return@mapNotNull parse(nodeObject, context)
        }

        return document
    }

    private fun parse(nodeObject: JsonObject, context: JsonDeserializationContext?): ProsemirrorNode? {

        when (nodeObject.get("type").asString) {
            NodeText.type -> {
                return parseNodeText(nodeObject)
            }
            NodeParagraph.type -> {
                return parseParagraph(nodeObject, context)
            }
            NodeHardBreak.type -> {
                return NodeHardBreak()
            }
            NodeBlockquote.type -> {
                return parseBlockquote(nodeObject, context)
            }
            NodeBulletList.type -> {
                return parseBulletList(nodeObject, context)
            }
            NodeHeadline.type -> {
                return parseHeadline(nodeObject, context)
            }
            NodeHorizontalRule.type -> {
                return NodeHorizontalRule()
            }
            NodeListItem.type -> {
                return parseListItem(nodeObject, context)
            }
            NodeOrderedList.type -> {
                return parseOrderedList(nodeObject, context)
            }
        }

        return null

    }

    private fun parseBlockquote(
        nodeObject: JsonObject,
        context: JsonDeserializationContext?
    ): NodeBlockquote {

        return NodeBlockquote(
            content = nodeObject.get("content").asJsonArray.mapNotNull { node ->
            return@mapNotNull parse(node.asJsonObject, context)
        }
        )

    }

    private fun parseBulletList(
        nodeObject: JsonObject,
        context: JsonDeserializationContext?
    ): NodeBulletList {

        return NodeBulletList(
            content = nodeObject.get("content").asJsonArray.mapNotNull { node ->
                return@mapNotNull parse(node.asJsonObject, context)
            }
        )

    }

    private fun parseOrderedList(
        nodeObject: JsonObject,
        context: JsonDeserializationContext?
    ): NodeOrderedList {

        return NodeOrderedList(
            content = nodeObject.get("content").asJsonArray.mapNotNull { node ->
                return@mapNotNull parse(node.asJsonObject, context)
            }
        )

    }

    private fun parseListItem(
        nodeObject: JsonObject,
        context: JsonDeserializationContext?
    ): NodeListItem {

        return NodeListItem(
            content = nodeObject.get("content").asJsonArray.mapNotNull { node ->
                return@mapNotNull parse(node.asJsonObject, context)
            }
        )

    }

    private fun parseParagraph(jsonObject: JsonObject, context: JsonDeserializationContext?): NodeParagraph {

        val attributes = if (jsonObject.has("attrs")) {
            context?.deserialize<ParagraphAttributes>(jsonObject.getAsJsonObject("attrs"), ParagraphAttributes::class.java)
        } else {
            null
        }

        return NodeParagraph(
            type = jsonObject.get("type").asString,
            content = jsonObject.get("content").asJsonArray.mapNotNull { node ->
                val nodeObject = node.asJsonObject
                return@mapNotNull parse(nodeObject, context)
            },
            attributes = attributes
        )
    }

    private fun parseHeadline(
        jsonObject: JsonObject,
        context: JsonDeserializationContext?
    ): NodeHeadline {

        val attributes = if (jsonObject.has("attrs")) {
            context?.deserialize<HeadlineAttributes>(jsonObject.getAsJsonObject("attrs"), HeadlineAttributes::class.java)
        } else {
            null
        }

        return NodeHeadline(
            type = jsonObject.get("type").asString,
            content = jsonObject.get("content").asJsonArray.mapNotNull { node ->
                val nodeObject = node.asJsonObject
                return@mapNotNull parse(nodeObject, context)
            },
            attributes = attributes
        )
    }

    private fun parseNodeText(jsonObject: JsonObject): NodeText {

        val marks = if (jsonObject.has("marks")) {
            jsonObject.get("marks").asJsonArray.map { mark ->
                val markObject = mark.asJsonObject
                return@map parseMark(markObject)
            }
        } else {
            listOf()
        }

        return NodeText(
            type = jsonObject.get("type").asString,
            text = jsonObject.get("text").asString,
            marks = marks
        )
    }

    private fun parseMark(markObject: JsonObject): MarkType {

        return when (markObject.get("type").asString) {
            MarkType.boldType -> {
                MarkType.Bold
            }
            MarkType.italicType -> {
                MarkType.Italic
            }
            MarkType.underlineType -> {
                MarkType.Underline
            }
            MarkType.strikeType -> {
                MarkType.Strike
            }
            MarkType.superscriptType -> {
                MarkType.Superscript
            }
            MarkType.linkType -> {
                val attrs = markObject.get("attrs").asJsonObject
                MarkType.Link(
                    MarkLinkAttributes(
                        href = attrs.get("href").asString
                    )
                )
            }

            else -> {
                error("This mark type is unknown.")
            }
        }
    }

}