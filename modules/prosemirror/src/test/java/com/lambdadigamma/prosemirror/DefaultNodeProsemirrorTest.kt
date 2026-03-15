package com.lambdadigamma.prosemirror

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.lambdadigamma.prosemirror.serialization.registerProsemirrorConverter
import kotlin.test.assertEquals

open class DefaultNodeProsemirrorTest {

    internal val gson: Gson = GsonBuilder()
        .registerProsemirrorConverter()
        .create()

    fun assertEncodeCorrect(encoding: Document, expectedJson: String) {
        val json = gson.toJson(encoding)
        assertEquals(expectedJson, json)
    }

    fun assertDecodeCorrect(json: String, expectedDocument: Document) {
        val document = gson.fromJson(json, Document::class.java)
        assertEquals(expectedDocument, document)
    }

}