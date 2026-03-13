package com.lambdadigamma.prosemirror.serialization

import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonNull
import com.google.gson.JsonObject
import com.google.gson.JsonSerializationContext
import com.google.gson.JsonSerializer
import com.lambdadigamma.prosemirror.Document
import com.lambdadigamma.prosemirror.nodes.MarkType
import com.lambdadigamma.prosemirror.nodes.NodeBlockquote
import com.lambdadigamma.prosemirror.nodes.NodeBulletList
import com.lambdadigamma.prosemirror.nodes.NodeHeadline
import com.lambdadigamma.prosemirror.nodes.NodeListItem
import com.lambdadigamma.prosemirror.nodes.NodeOrderedList
import com.lambdadigamma.prosemirror.nodes.ProsemirrorNode
import com.lambdadigamma.prosemirror.nodes.NodeParagraph
import com.lambdadigamma.prosemirror.nodes.NodeText
import java.lang.reflect.Type

class DocumentSerializer : JsonSerializer<Document> {

    override fun serialize(
        src: Document?,
        typeOfSrc: Type?,
        context: JsonSerializationContext?
    ): JsonElement {

        val documentObject = JsonObject()

        if (src == null) {
            documentObject.addProperty("type", Document.type)
            documentObject.add("content", JsonArray())
        } else {
            documentObject.addProperty("type", Document.type)

            val topLevelNodesArray = JsonArray()
            src.content.forEach { node ->
                val nodeElement = serializeNode(node, context)
                topLevelNodesArray.add(nodeElement)
            }

            documentObject.add("content", topLevelNodesArray)
        }

        return documentObject
    }

    private fun serializeNode(node: ProsemirrorNode, context: JsonSerializationContext?): JsonElement {
        val nodeObject = JsonObject()
        nodeObject.addProperty("type", node.type)

        when (node) {
            is NodeHeadline -> {
                serializeNodeHeadline(node, context, nodeObject)
            }
            is NodeParagraph -> {
                serializeNodeParagraph(node, context, nodeObject)
            }
            is NodeText -> {
                serializeNodeText(node, context, nodeObject)
            }
            is NodeBlockquote -> {
                serializeNodeBlockquote(node, context, nodeObject)
            }
            is NodeBulletList -> {
                serializeNodeBulletList(node, context, nodeObject)
            }
            is NodeListItem -> {
                serializeNodeListItem(node, context, nodeObject)
            }
            is NodeOrderedList -> {
                serializeNodeOrderedList(node, context, nodeObject)
            }
        }

        return nodeObject
    }

    private fun serializeNodeListItem(
        node: NodeListItem,
        context: JsonSerializationContext?,
        nodeObject: JsonObject
    ) {
        val contentArray = JsonArray()

        node.content?.forEach { nestedNode ->
            val nestedNodeElement = serializeNode(nestedNode, context)
            contentArray.add(nestedNodeElement)
        }
        nodeObject.add("content", contentArray)
    }

    private fun serializeNodeBlockquote(
        node: NodeBlockquote,
        context: JsonSerializationContext?,
        nodeObject: JsonObject
    ) {
        val contentArray = JsonArray()

        node.content?.forEach { nestedNode ->
            val nestedNodeElement = serializeNode(nestedNode, context)
            contentArray.add(nestedNodeElement)
        }
        nodeObject.add("content", contentArray)
    }

    private fun serializeNodeParagraph(
        node: NodeParagraph,
        context: JsonSerializationContext?,
        nodeObject: JsonObject
    ) {
        val contentArray = JsonArray()

        node.content?.forEach { nestedNode ->
            val nestedNodeElement = serializeNode(nestedNode, context)
            contentArray.add(nestedNodeElement)
        }
        nodeObject.add("content", contentArray)

        if (node.attributes != null) {
            nodeObject.add("attrs", context?.serialize(node.attributes) ?: JsonNull.INSTANCE)
        }

    }

    private fun serializeNodeHeadline(
        node: NodeHeadline,
        context: JsonSerializationContext?,
        nodeObject: JsonObject
    ) {
        val contentArray = JsonArray()

        node.content?.forEach { nestedNode ->
            val nestedNodeElement = serializeNode(nestedNode, context)
            contentArray.add(nestedNodeElement)
        }
        nodeObject.add("content", contentArray)

        if (node.attributes != null) {
            nodeObject.add("attrs", context?.serialize(node.attributes) ?: JsonNull.INSTANCE)
        }

    }

    private fun serializeNodeBulletList(
        node: NodeBulletList,
        context: JsonSerializationContext?,
        nodeObject: JsonObject
    ) {
        val contentArray = JsonArray()

        node.content?.forEach { nestedNode ->
            val nestedNodeElement = serializeNode(nestedNode, context)
            contentArray.add(nestedNodeElement)
        }
        nodeObject.add("content", contentArray)
    }

    private fun serializeNodeOrderedList(
        node: NodeOrderedList,
        context: JsonSerializationContext?,
        nodeObject: JsonObject
    ) {
        val contentArray = JsonArray()

        node.content?.forEach { nestedNode ->
            val nestedNodeElement = serializeNode(nestedNode, context)
            contentArray.add(nestedNodeElement)
        }
        nodeObject.add("content", contentArray)
    }

    private fun serializeNodeText(
        node: NodeText,
        context: JsonSerializationContext?,
        nodeObject: JsonObject
    ) {
        val marksArray = JsonArray()
        node.marks.forEach { mark ->
            val markElement = serializeMark(mark, context)
            marksArray.add(markElement)
        }
        nodeObject.addProperty("text", node.text)
        nodeObject.add("marks", marksArray)
    }

    private fun serializeMark(mark: MarkType, context: JsonSerializationContext?): JsonElement {
        val markObject = JsonObject()

        when (mark) {
            is MarkType.Bold -> {
                markObject.addProperty("type", MarkType.boldType)
            }
            is MarkType.Italic -> {
                markObject.addProperty("type", MarkType.italicType)
            }
            is MarkType.Underline -> {
                markObject.addProperty("type", MarkType.underlineType)
            }
            is MarkType.Strike -> {
                markObject.addProperty("type", MarkType.strikeType)
            }
            is MarkType.Superscript -> {
                markObject.addProperty("type", MarkType.superscriptType)
            }
            is MarkType.Link -> {
                markObject.addProperty("type", MarkType.linkType)
                val attrsObject = JsonObject()
                if (mark.attrs?.href == null) {
                    attrsObject.add("href", JsonNull.INSTANCE)
                } else {
                    attrsObject.addProperty("href", mark.attrs.href)
                }
                markObject.add("attrs", attrsObject)
            }
        }

        return markObject
    }

}
