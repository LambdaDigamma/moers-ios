package app.moers.core.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import app.moers.core.R

data class AddressUiState(
    val street: String,
    val houseNumber: String,
    val city: String,
    val state: String,
    val zip: String
)

@Composable
fun AddressContainer(
    modifier: Modifier = Modifier,
    label: String? = null,
    address: AddressUiState
) {

    val firstLine = remember(address) {
        "${address.street} ${address.houseNumber}"
    }
    val secondLine = remember(address) {
        buildAnnotatedString {
            append(address.zip)
            append(" ")
            append(address.city)
        }
    }

    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(
            text = label ?: stringResource(R.string.address_headline),
            fontWeight = FontWeight.Bold
        )
        Text(text = firstLine, fontWeight = FontWeight.Normal, style = MaterialTheme.typography.bodyMedium)
        Text(text = secondLine, fontWeight = FontWeight.Normal, style = MaterialTheme.typography.bodyMedium)
    }

}

@Preview(showBackground = true)
@Composable
fun AddressPreview() {
    MaterialTheme() {
        AddressContainer(
            label = "Adresse",
            address = AddressUiState(
                street = "Königsstraße",
                houseNumber = "1a",
                city = "Musterstadt",
                state = "Musterland",
                zip = "12345"
            )
        )
    }
}