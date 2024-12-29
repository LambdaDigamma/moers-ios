package com.lambdadigamma.events.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.lambdadigamma.core.isToday
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.events.models.Event
import java.util.*

data class EventUi(
    val id: Int,
    val name: String,
    val description: String?,
    val date: String,
    val isLive: Boolean = false,
    val isToday: Boolean = false,
    val attendanceMode: EventAttendanceMode = EventAttendanceMode.OFFLINE,
) {

    constructor(event: Event) : this(
        id = event.id,
        name = event.name,
        description = event.description,
        date = EventDetailUiState.dateString(event.startDate, event.endDate) ?: "",
        isLive = EventDetailUiState.isActive(event.startDate, event.endDate),
        isToday = event.startDate?.let { startDate ->
            return@let isToday(startDate) || event.endDate?.let { it > Date() && startDate < Date() } == true
        } == true,
        attendanceMode = event.extras?.attendanceMode ?: defaultAttendanceMode
    )

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventOverviewList(
    todayEvents: List<EventUi>,
    longTermEvents: List<EventUi>,
    onSelectEvent: (Int) -> Unit
) {

    val today = remember {
        todayEvents.filter { it.isToday }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.surface)
            .verticalScroll(rememberScrollState())
    ) {

        SectionHeader(
            text = "Heute",
            onClick = {}
        )

        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            for (event in todayEvents) {
                EventRow(event = event,
                    modifier = Modifier
                        .clickable { onSelectEvent(event.id) }
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                )
            }
        }
//        OutlinedCard(modifier = Modifier.padding(16.dp)) {
//        }

        SectionHeader(
            text = "Längere Zeit in Moers",
            onClick = {},
            showMore = false
        )

        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            for (event in longTermEvents) {
                EventRow(event = event,
                    modifier = Modifier
                        .clickable { onSelectEvent(event.id) }
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                )
            }
        }
//        OutlinedCard(modifier = Modifier.padding(16.dp)) {
//        }

    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun BigEventCard() {

    ElevatedCard(
        modifier = Modifier
            .padding(16.dp),
        elevation = CardDefaults.elevatedCardElevation()
    ) {
        Box(
            modifier = Modifier,
//                    .padding(16.dp)
//                    .clip(RoundedCornerShape(12.dp))
//                    .shadow(4.dp),
            contentAlignment = Alignment.BottomStart
        ) {
            AsyncImage(
                model = "https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1600&q=80",
                contentDescription = null,
                alignment = Alignment.TopCenter,
                contentScale = ContentScale.FillWidth,
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(ratio = (16.0f / 9.0f))
            )
            Row(
                modifier = Modifier
//                        .background(Color.Black.copy(0.5f))
                    .padding(16.dp)
                    .fillMaxWidth()
            ) {
                Text(
                    text = "Julius Henri @ main stage",
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier
                        .shadow(elevation = 4.dp),
                    color = Color.White,
                    style = MaterialTheme.typography.titleMedium
                )
            }
        }
    }

}

@Composable
private fun SectionHeader(text: String, onClick: () -> Unit, showMore: Boolean = true) {
    Row(
        modifier = Modifier
            .clickable { onClick() }
            .padding(horizontal = 16.dp)
            .fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Medium
        )

        if (showMore) {
            IconButton(onClick = onClick) {
                Icon(imageVector = Icons.Filled.ArrowForward, contentDescription = "Alle ansehen")
            }
        }
    }
}

@Preview
@Composable
fun EventOverviewListPreview() {

    val items = listOf(
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

    MeinMoersTheme {
        EventOverviewList(items, items, onSelectEvent = {})
    }
}