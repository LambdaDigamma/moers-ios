package com.lambdadigamma.medialibrary

import android.content.Context
import android.graphics.Color
import coil3.ColorImage
import coil3.ImageLoader
import coil3.decode.DecodeResult
import coil3.decode.Decoder
import coil3.request.CachePolicy
import coil3.request.ImageRequest

fun prefetchToDisk(
    image: String,
    context: Context,
    imageLoader: ImageLoader
) {
    val request = ImageRequest.Builder(context)
        .data(image)
        .memoryCachePolicy(CachePolicy.DISABLED)
        .decoderFactory { _, _, _ ->
            Decoder {
                DecodeResult(
                    image = ColorImage(Color.BLACK),
                    isSampled = false
                )
            }
        }
        .build()

    imageLoader.enqueue(request)
}