package com.lambdadigamma.events.ui

import android.content.Intent
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.lambdadigamma.core.geo.GoogleMapsNavigationProvider
import com.lambdadigamma.core.geo.TravelMode
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.core.ui.ResourcefulContent
import com.lambdadigamma.core.ui.VenueCard
import com.lambdadigamma.events.R

/*
- Title
- Ort (optional)
- Datum (optional)
- Detail Text
-
 */

@Composable
fun EventDetailScreen(
    id: Int,
    onBack: () -> Unit,
    onSelectVenue: () -> Unit = {},
) {

    val viewModel: EventDetailViewModel = hiltViewModel()
    viewModel.eventId = id
    val event = viewModel.load()

    ResourcefulContent(resource = event, onLoad = { /*TODO*/ }) {
        it?.let {
            EventDetail(
                event = EventDetailUiState(it),
                onBack = onBack
            )
        }
    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun EventDetail(event: EventDetailUiState, onBack: () -> Unit) {

    val sendIntent: Intent = Intent().apply {
        action = Intent.ACTION_SEND
        putExtra(Intent.EXTRA_TEXT, event.url)
        putExtra(Intent.EXTRA_TITLE, event.name)
        type = "text/plain"
    }
    val context = LocalContext.current

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(text = "Details")
                },
                navigationIcon = {
                    NavigationBackButton(onBack = onBack)
                },
                actions = {
                    IconButton(
                        onClick = {
                            context.startActivity(sendIntent)
                        },
                        content = {
                            Icon(imageVector = Icons.Default.Share, contentDescription = null)
                        }
                    )
                }
            )
        },
        content = {
            Column(
                modifier = Modifier
                    .padding(it)
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
            ) {

//                Box(
//                    modifier = Modifier
//                        .height(240.dp)
//                        .fillMaxWidth()
//                        .background(MaterialTheme.colorScheme.surfaceVariant)
//                )

//                AsyncImage(
//                    model = "https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1600&q=80",
//                    contentDescription = null,
//                    alignment = Alignment.TopCenter,
//                    contentScale = ContentScale.FillWidth,
//                    modifier = Modifier
//                        .fillMaxWidth()
//                        .aspectRatio(ratio = (16.0f / 9.0f))
//                )

                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {

                    Text(
                        text = event.name,
                        fontWeight = FontWeight.SemiBold,
                        style = MaterialTheme.typography.titleLarge,
                        lineHeight = MaterialTheme.typography.headlineSmall.lineHeight * 0.9
                    )

                    val location: String =
                        event.venue?.name ?: stringResource(R.string.event_detail_no_place)

                    Text(
                        text = "$location • ${event.date}",
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.secondary,
                    )

                    event.description?.let { description ->
                        SelectionContainer {
                            Text(
                                text = description,
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.secondary
                            )
                        }
                    }

                }

                VenueCard(
                    modifier = Modifier.padding(16.dp),
                    address = event.venue,
                    onNavigate = { address ->
                        GoogleMapsNavigationProvider(context).startNavigation(
                            address.name,
                            address.firstLine,
                            address.secondLine,
                            travelMode = TravelMode.WALKING
                        )
                    }
                )

                OrganizerCard(
                    organizer = event.organizer,
                    modifier = Modifier
                        .padding(horizontal = 16.dp)
                        .padding(bottom = 16.dp)
                )

//                Categories(
//                    categories = event.categories,
//                    modifier = Modifier
//                        .padding(top = 8.dp)
//                        .padding(horizontal = 16.dp)
//                        .padding(bottom = 8.dp)
//                )

            }
        }
    )

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun Categories(categories: List<String>, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(8.dp),

        ) {

//        val categories = listOf<String>(
//            "Ausstellungen",
//            "Information und Weiterbildung",
//            "Information",
//            "Weiterbildung"
//        )

        for (category in categories) {
            SuggestionChip(onClick = { /*TODO*/ }, label = {
                Text(text = category)
            })
        }

    }
}

@Preview(showBackground = true)
@Composable
fun EventDetailScreenPreview() {
    MeinMoersTheme {
        EventDetail(
            EventDetailUiState(
                id = 1,
                name = "Sonderausstellung: Mond.Landung",
                description = "Mit Virtual Reality das Weltall erobern. Am 21. Juli 1969 um 3:56 MEZ betraten die ersten beiden Menschen den Mond: Neil Armstrong und Buzz Aldrin. 500 Millionen Menschen verfolgten Armstrongs ersten Schritt auf dem pudrigen Boden gebannt am Fernsehbildschirm. Die Mission Apollo 11 war ein Erfolg.",
                date = "Mo, 19. Mai 2022"
            ),
            onBack = {}
        )
    }
}