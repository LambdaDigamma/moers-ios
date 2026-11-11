package com.lambdadigamma.rubbish.street

import com.lambdadigamma.rubbish.RubbishCollectionStreet
import org.junit.Assert.assertEquals
import org.junit.Test

class RubbishStreetFilterTest {

    private fun street(id: Int, name: String) = RubbishCollectionStreet(id, name, null, 0, 0, 0, 0, 0, null, 2026)

    private val streets = listOf(
        street(1, "Am Adlerhorst"),
        street(2, "Adlerstraße"),
        street(3, "Homberger Straße"),
        street(4, "Ährenweg"),
    )

    @Test
    fun `matches abbreviations and puts prefix matches first`() {
        assertEquals(listOf(2, 1), RubbishStreetPickerViewModel.filterStreets(streets, "adler").map { it.id })
        assertEquals(listOf(2), RubbishStreetPickerViewModel.filterStreets(streets, "Adlerstr.").map { it.id })
        assertEquals(listOf(3), RubbishStreetPickerViewModel.filterStreets(streets, "homberger strasse").map { it.id })
    }

    @Test
    fun `ignores umlauts`() {
        assertEquals(listOf(4), RubbishStreetPickerViewModel.filterStreets(streets, "ahren").map { it.id })
    }

    @Test
    fun `returns all streets for an empty query`() {
        assertEquals(4, RubbishStreetPickerViewModel.filterStreets(streets, " ").size)
    }
}
