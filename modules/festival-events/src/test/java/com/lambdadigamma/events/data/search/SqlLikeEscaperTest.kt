package com.lambdadigamma.events.data.search

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

class SqlLikeEscaperTest {

    @Test
    fun `should escape sqlite like wildcards and escape character`() {
        val escaped = SqlLikeEscaper.escape("50%_\\ jazz")

        assertEquals("50\\%\\_\\\\ jazz", escaped)
    }
}
