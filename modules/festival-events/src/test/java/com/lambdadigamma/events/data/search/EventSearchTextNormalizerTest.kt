package com.lambdadigamma.events.data.search

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

class EventSearchTextNormalizerTest {

    @Test
    fun `should normalize case diacritics special letters and whitespace`() {
        val normalized = EventSearchTextNormalizer.normalize("  Ærøskøbing  Straße   Noël Łódź  ")

        assertEquals("aeroskobing strasse noel lodz", normalized)
    }

    @Test
    fun `should return empty string for blank text`() {
        val normalized = EventSearchTextNormalizer.normalize(" \n\t ")

        assertEquals("", normalized)
    }
}
