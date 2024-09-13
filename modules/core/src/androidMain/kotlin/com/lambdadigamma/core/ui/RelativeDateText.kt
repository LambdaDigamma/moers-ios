package com.lambdadigamma.core.ui

import android.os.Handler
import android.os.Looper
import android.text.format.DateUtils
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.TextUnit
import java.util.*

@Composable
fun RelativeDateText(
    date: Date,
    color: Color = Color.Unspecified,
    fontSize: TextUnit = TextUnit.Unspecified,
    fontStyle: FontStyle? = null,
    fontWeight: FontWeight? = null,
    fontFamily: FontFamily? = null,
    letterSpacing: TextUnit = TextUnit.Unspecified,
    textDecoration: TextDecoration? = null,
    textAlign: TextAlign? = null,
    lineHeight: TextUnit = TextUnit.Unspecified,
    overflow: TextOverflow = TextOverflow.Clip,
    softWrap: Boolean = true,
    maxLines: Int = Int.MAX_VALUE,
    onTextLayout: (TextLayoutResult) -> Unit = {},
    style: TextStyle = LocalTextStyle.current
) {

    val value = autoUpdateRelativeTime(date = date)

    Text(
        text = value,
        color = color,
        fontSize = fontSize,
        fontStyle = fontStyle,
        fontWeight = fontWeight,
        fontFamily = fontFamily,
        letterSpacing = letterSpacing,
        textDecoration = textDecoration,
        textAlign = textAlign,
        lineHeight = lineHeight,
        overflow = overflow,
        softWrap = softWrap,
        maxLines = maxLines,
        onTextLayout = onTextLayout,
        style = style
    )

}

@Composable
private fun autoUpdateRelativeTime(date: Date): String {

    var value by remember { mutableStateOf(getRelative(date = date)) }

    DisposableEffect(Unit) {
        val handler = Handler(Looper.getMainLooper())

        val runnable = {
            value = getRelative(date = date)
        }

        handler.postDelayed(runnable, 60_000)

        onDispose {
            handler.removeCallbacks(runnable)
        }
    }

    return value

}

private fun getRelative(date: Date): String {
    return DateUtils.getRelativeTimeSpanString(
        date.time,
        Date().time,
        DateUtils.SECOND_IN_MILLIS
    ).toString()
}


@Preview
@Composable
fun RelativeDateTextPreview() {
    RelativeDateText(Date())
}
