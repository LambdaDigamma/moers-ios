package com.lambdadigamma.moersfestival.ui

import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import com.lambdadigamma.moersfestival.FestivalNavKey

@Composable
fun BottomBar(
    currentTopLevelKey: FestivalNavKey,
    tabs: Array<AppTab>,
    onTabSelected: (FestivalNavKey) -> Unit,
) {
    NavigationBar {
        tabs.forEach { tab ->
            val selected = tab.key == currentTopLevelKey
            NavigationBarItem(
                icon = {
                    Icon(
                        painterResource(id = if (selected) tab.activeIcon else tab.inactiveIcon),
                        contentDescription = null,
                    )
                },
                label = {
                    Text(text = stringResource(id = tab.title))
                },
                selected = selected,
                onClick = {
                    if (!selected) {
                        onTabSelected(tab.key)
                    }
                },
            )
        }
    }
}
