package com.lambdadigamma.rubbish.ui

import android.content.Context
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import androidx.work.WorkManager
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.rubbish.notifications.RubbishScheduleNotificationWorker
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

data class DebugNotification(val date: String, val data: String)

@HiltViewModel
class DebugRubbishNotificationViewModel @Inject constructor(
    @ApplicationContext val context: Context
) : ViewModel() {

    fun load(): LiveData<List<DebugNotification>> {

        val workManager = WorkManager.getInstance(context)

        return Transformations.map(
            workManager.getWorkInfosByTagLiveData(RubbishScheduleNotificationWorker.TAG)
        ) {
            return@map it.map { DebugNotification(it.id.toString(), "") }
        }

    }

}

@Composable
fun DebugNotificationScreen() {

    val viewModel: DebugRubbishNotificationViewModel = hiltViewModel()
    val items by viewModel.load().observeAsState()

    DebugRubbishNotificationList(items = items.orEmpty())

}

@Composable
fun DebugRubbishNotificationList(items: List<DebugNotification>) {

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
//        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(items) { item ->
            DebugRubbishNotificationItem(date = item.date, data = item.data)
        }
    }
}

@Composable
fun DebugRubbishNotificationItem(date: String, data: String) {
    Column(modifier = Modifier.padding(all = 16.dp)) {
        Text(text = date, fontWeight = FontWeight.SemiBold)
        Text(text = data, color = MaterialTheme.colorScheme.secondary)
    }
}

@Preview
@Composable
fun DebugRubbishNotificationListPreview() {
    MeinMoersTheme {
        DebugRubbishNotificationList(
            listOf(
                DebugNotification("2022-01-05", "Rubbish: Green"),
                DebugNotification("2022-01-08", "Rubbish: Plastic"),
                DebugNotification("2022-01-10", "Rubbish: Cuttings"),
                DebugNotification("2022-01-14", "Rubbish: Yellow")
            )
        )
    }
}