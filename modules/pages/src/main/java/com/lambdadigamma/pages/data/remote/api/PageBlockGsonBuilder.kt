package com.lambdadigamma.pages.data.remote.api

import com.google.gson.GsonBuilder
import com.lambdadigamma.core.utils.GsonUTCDateAdapter
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerDeserializer
import com.lambdadigamma.medialibrary.MediaCollectionsContainerSerializer
import com.lambdadigamma.pages.data.remote.model.PageBlock
import com.lambdadigamma.prosemirror.Document
import com.lambdadigamma.prosemirror.serialization.DocumentDeserializer
import com.lambdadigamma.prosemirror.serialization.DocumentSerializer
import java.util.Date

fun GsonBuilder.registerPageBlockTypeAdapter() = apply {
    registerTypeAdapter(PageBlock::class.java, PageBlockDeserializer())
    registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerDeserializer())
    registerTypeAdapter(MediaCollectionsContainer::class.java, MediaCollectionsContainerSerializer())
    registerTypeAdapter(Document::class.java, DocumentDeserializer())
    registerTypeAdapter(Document::class.java, DocumentSerializer())
    registerTypeAdapter(Date::class.java, GsonUTCDateAdapter())
}