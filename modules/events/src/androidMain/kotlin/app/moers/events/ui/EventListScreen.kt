package com.lambdadigamma.events.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import com.lambdadigamma.core.theme.MeinMoersTheme

@Composable
fun EventListScreen() {


}

@Composable
fun EventListContent() {

    val events = listOf(
        EventUi(
            id = 1,
            name = "Sonderausstellung: Mond.Landung",
            description = "Mit Virtual Reality das Weltallerobern. Am 21. Juli 1969 um 3:56 MEZ betraten die ersten beiden Menschen den Mond: Neil Armstrong und Buzz Aldrin. 500 Millionen Menschen verfolgten Armstrongs ersten Schritt auf dem pudrigen Boden gebannt am Fernsehbildschirm. Die Mission Apollo 11 war ein Erfolg.",
            date = "Mo, 19. Mai 2022",
            isToday = true
        ),
        EventUi(
            id = 2,
            name = "Open Air Lichtspiele im Schlosshof",
            description = "",
            date = "Di, 20. Mai 2022",
            isToday = true
        ),
        EventUi(
            id = 3,
            name = "Fahrradtour mit dem Bürgermeister",
            description = "",
            date = "Mi, 21. Mai 2022"
        ),
        EventUi(
            id = 4,
            name = "Leseabend für Kinder und Jugendliche von 6-14 Jahren",
            description = "",
            date = "Mi, 21. Mai 2022",
            isToday = true,
        )
    )

}

@Preview
@Composable
private fun EventListContentPreview() {
    MeinMoersTheme {
        EventListContent()
    }
}