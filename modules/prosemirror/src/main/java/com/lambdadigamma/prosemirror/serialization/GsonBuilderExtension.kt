package com.lambdadigamma.prosemirror.serialization

import com.google.gson.GsonBuilder
import com.lambdadigamma.prosemirror.Document

fun GsonBuilder.registerProsemirrorConverter(): GsonBuilder {

    val documentDeserializer = DocumentDeserializer()
    val documentSerializer = DocumentSerializer()

    return this
        .registerTypeAdapter(Document::class.java, documentDeserializer)
        .registerTypeAdapter(Document::class.java, documentSerializer)

}