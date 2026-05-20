package com.lambdadigamma.events.data.search

object SqlLikeEscaper {

    fun escape(value: String): String = buildString {
        value.forEach { character ->
            if (character == '%' || character == '_' || character == '\\') {
                append('\\')
            }
            append(character)
        }
    }
}
