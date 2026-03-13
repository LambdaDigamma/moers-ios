package com.lambdadigamma.moers

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import com.jamal.composeprefs3.ui.GroupHeader
import com.jamal.composeprefs3.ui.PrefsScreen
import com.jamal.composeprefs3.ui.prefs.DropDownPref
import com.jamal.composeprefs3.ui.prefs.SwitchPref
import com.jamal.composeprefs3.ui.prefs.TextPref
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.ui.NavigationBackButton
import com.lambdadigamma.core.user.UserRepository
import com.lambdadigamma.core.user.UserType
import com.lambdadigamma.core.utils.dataStore
import com.lambdadigamma.fuel.data.FuelRepository
import com.lambdadigamma.fuel.data.FuelType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(onBack: () -> Unit) {

    Scaffold(topBar = {
        LargeTopAppBar(
            title = { Text(text = stringResource(id = R.string.settings)) },
            navigationIcon = {
                NavigationBackButton(onBack = onBack)
            },
            colors = TopAppBarDefaults.largeTopAppBarColors()
        )
    }) {
        PrefsScreen(
            dataStore = LocalContext.current.dataStore,
            modifier = Modifier.padding(it)
        ) {

            prefsGroup(
                header = { GroupHeader(title = stringResource(R.string.settings_user_header)) }
            ) {
                prefsItem {
                    DropDownPref(
                        key = UserRepository.userTypeKey.name,
                        title = stringResource(R.string.settings_user_type),
                        useSelectedAsSummary = true,
                        entries = mapOf(
                            UserType.CITIZEN.value to stringResource(R.string.settings_user_type_citizen),
                            UserType.VISITOR.value to stringResource(R.string.settings_user_type_guest),
                        ),
                        defaultValue = UserRepository.defaultUserType.value
                    )
                }
            }

            prefsGroup(
                header = { GroupHeader(title = stringResource(R.string.settings_fuel_header)) }
            ) {
                prefsItem {
                    DropDownPref(
                        key = FuelRepository.fuelTypeKey.name,
                        title = stringResource(R.string.settings_fuel_type_label),
                        useSelectedAsSummary = true,
                        entries = mapOf(
                            FuelType.DIESEL.value to FuelType.DIESEL.localizedName(),
                            FuelType.E5.value to FuelType.E5.localizedName(),
                            FuelType.E10.value to FuelType.E10.localizedName(),
                        ),
                        defaultValue = FuelRepository.defaultFuelType.value
                    )
                }
            }

            prefsGroup(
                header = { GroupHeader(title = stringResource(R.string.settings_rubbish_header)) }
            ) {
                prefsItem {
                    SwitchPref(
                        key = "rubbish_schedule_active",
                        title = stringResource(R.string.settings_rubbish_schedule_active),
                    )
                    TextPref(
                        title = stringResource(R.string.settings_rubbish_street),
                        summary = "Adlerstraße",
                        onClick = {}
                    )
                    TextPref(
                        title = stringResource(R.string.settings_rubbish_reminder_time),
                        summary = "20:00 Uhr am Vortag",
                        onClick = {}
                    )
                }
            }

            /*
            - [ ] Benutzer
                - [ ] Art
            - [ ] Tanken
                - [ ] Kraftstoff
            - [ ] Abfuhrkalender
                - [ ] Aktiviert
                - [ ] Straße
                - [ ] Erinnerung
             */

        }
    }

}

@Preview
@Composable
fun SettingsScreenPreviews() {
    MeinMoersTheme {
        SettingsScreen(onBack = {})
    }
}
