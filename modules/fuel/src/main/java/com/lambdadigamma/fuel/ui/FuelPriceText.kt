package com.lambdadigamma.fuel.ui

import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.*
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.BaselineShift
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.TextUnit
import com.lambdadigamma.core.theme.MeinMoersTheme

@Composable
fun FuelPriceText(
    price: Double,
    showSmall9: Boolean = true,
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
    style: TextStyle = LocalTextStyle.current,
    modifier: Modifier = Modifier
) {

    val formatted = remember(price) { String.format(if (showSmall9) "%.3f" else "%.2f", price) }
    val superscript = remember {
        SpanStyle(
            baselineShift = BaselineShift.Superscript,
            fontSize = style.fontSize * 0.8f,
        )
    }

    Text(
        text = buildAnnotatedString {
            append(formatted.dropLast(if (showSmall9) 1 else 0))
            if (showSmall9) {
                withStyle(superscript) {
                    append(formatted.last())
                }
            }
            append("€")
        },
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
        style = style,
        modifier = modifier
    )

}

@Preview
@Composable
private fun FuelPricePreview() {
    MeinMoersTheme {
        FuelPriceText(price = 1.899)
    }
}