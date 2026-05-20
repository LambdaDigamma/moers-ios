package com.lambdadigamma.events.data.search

import java.text.Normalizer
import java.util.Locale

object EventSearchTextNormalizer {

    private val replacementPairs = listOf(
        "Æ" to "AE",
        "æ" to "ae",
        "Œ" to "OE",
        "œ" to "oe",
        "Ø" to "O",
        "ø" to "o",
        "Ł" to "L",
        "ł" to "l",
        "Ð" to "D",
        "ð" to "d",
        "Đ" to "D",
        "đ" to "d",
        "ß" to "ss",
    )
    private val combiningMarksRegex = "\\p{Mn}+".toRegex()
    private val whitespaceRegex = "\\s+".toRegex()

    fun normalize(text: String): String {
        val replacedText = replacementPairs.fold(text) { currentText, replacement ->
            currentText.replace(replacement.first, replacement.second)
        }
        val normalizedText = Normalizer.normalize(replacedText, Normalizer.Form.NFKD)

        return normalizedText
            .replace(combiningMarksRegex, "")
            .lowercase(Locale.GERMANY)
            .trim()
            .replace(whitespaceRegex, " ")
    }
}
