package com.lambdadigamma.rubbish.widget

import android.content.Context
import android.text.format.DateFormat
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.updateAll
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import com.lambdadigamma.rubbish.R
import com.lambdadigamma.rubbish.RubbishPickupDay
import com.lambdadigamma.rubbish.RubbishRepository
import com.lambdadigamma.rubbish.RubbishScheduleViewModel.Companion.toDays
import com.lambdadigamma.rubbish.icon
import com.lambdadigamma.rubbish.labelRes
import dagger.hilt.EntryPoint
import dagger.hilt.InstallIn
import dagger.hilt.android.EntryPointAccessors
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.flow.first
import java.time.LocalDate
import java.time.format.DateTimeFormatter

@EntryPoint
@InstallIn(SingletonComponent::class)
interface RubbishWidgetEntryPoint {
    fun rubbishRepository(): RubbishRepository
}

/** Home screen widget with the next waste collection days of the user's street. */
class RubbishWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Responsive(setOf(SMALL, LARGE))

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val repository = EntryPointAccessors
            .fromApplication(context, RubbishWidgetEntryPoint::class.java)
            .rubbishRepository()
        val hasStreet = repository.currentStreet.first() != null
        val days = repository.upcomingPickups.first().toDays()

        provideContent {
            GlanceTheme {
                RubbishWidgetContent(hasStreet = hasStreet, days = days)
            }
        }
    }

    companion object {
        private val SMALL = DpSize(110.dp, 110.dp)
        private val LARGE = DpSize(250.dp, 110.dp)

        suspend fun updateAll(context: Context) = RubbishWidget().updateAll(context)
    }
}

class RubbishWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = RubbishWidget()
}

@Composable
private fun RubbishWidgetContent(hasStreet: Boolean, days: List<RubbishPickupDay>) {
    val context = LocalContext.current
    val isLarge = LocalSize.current.width >= 250.dp
    val openApp = context.packageManager.getLaunchIntentForPackage(context.packageName)

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .appWidgetBackground()
            .background(GlanceTheme.colors.widgetBackground)
            .cornerRadius(16.dp)
            .padding(12.dp)
            .then(if (openApp != null) GlanceModifier.clickable(actionStartActivity(openApp)) else GlanceModifier),
    ) {
        Text(
            text = context.getString(R.string.rubbish_collection_title),
            style = TextStyle(
                color = GlanceTheme.colors.primary,
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
            ),
            maxLines = 1,
        )
        Spacer(GlanceModifier.height(8.dp))

        when {
            !hasStreet -> BodyText(context.getString(R.string.rubbish_widget_no_street))
            days.isEmpty() -> BodyText(context.getString(R.string.rubbish_no_pickups))
            else -> days.take(if (isLarge) 3 else 2).forEach { day ->
                PickupDay(day = day, showAllTypes = isLarge)
                Spacer(GlanceModifier.height(6.dp))
            }
        }
    }
}

@Composable
private fun PickupDay(day: RubbishPickupDay, showAllTypes: Boolean) {
    val context = LocalContext.current
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        Text(
            text = dayLabel(context, day.date),
            style = TextStyle(
                color = GlanceTheme.colors.onSurface,
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
            ),
            maxLines = 1,
        )
        Row(verticalAlignment = Alignment.CenterVertically) {
            day.types.take(if (showAllTypes) day.types.size else 2).forEach { type ->
                Image(
                    provider = ImageProvider(type.icon()),
                    contentDescription = null,
                    modifier = GlanceModifier.size(16.dp),
                )
                Spacer(GlanceModifier.width(4.dp))
                if (showAllTypes || day.types.size == 1) {
                    Text(
                        text = context.getString(type.labelRes()),
                        style = TextStyle(color = GlanceTheme.colors.onSurfaceVariant, fontSize = 12.sp),
                        maxLines = 1,
                    )
                    Spacer(GlanceModifier.width(8.dp))
                }
            }
        }
    }
}

@Composable
private fun BodyText(text: String) {
    Text(
        text = text,
        style = TextStyle(color = GlanceTheme.colors.onSurfaceVariant, fontSize = 13.sp),
    )
}

private fun dayLabel(context: Context, date: LocalDate): String {
    val today = LocalDate.now()
    return when (date) {
        today -> context.getString(R.string.rubbish_today)
        today.plusDays(1) -> context.getString(R.string.rubbish_tomorrow)
        else -> {
            val locale = context.resources.configuration.locales[0]
            date.format(DateTimeFormatter.ofPattern(DateFormat.getBestDateTimePattern(locale, "EEEMMMd"), locale))
        }
    }
}
