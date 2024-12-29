package com.lambdadigamma.parking.detail

import android.graphics.PointF
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Divider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme

private sealed class LinearChartStyle {
    object Default : LinearChartStyle()
    object Smooth : LinearChartStyle()
}

@Composable
private fun LinearChart(
    modifier: Modifier = Modifier,
    height: Dp,
    style: LinearChartStyle = LinearChartStyle.Default,
    data: List<Int>
) {
    Column(modifier = modifier) {
        Row {
            Column(
                verticalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier
                    .height(height)
                    .padding(end = 4.dp),
                horizontalAlignment = Alignment.End
            ) {
                val points = arrayOf("100%", "75%", "50%", "25%", "0%")

                for (point in points) {
                    Text(
                        text = point,
                        color = MaterialTheme.colorScheme.tertiary,
                        style = MaterialTheme.typography.labelSmall,
                        textAlign = TextAlign.End
                    )
                }
            }

            val lineColor = MaterialTheme.colorScheme.primary

            Divider(
                modifier = Modifier
                    .height(height)
                    .width(1.dp),
                thickness = 1.dp,
                color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f)
            )
            Column {
                Canvas(
                    modifier = Modifier
                        .height(height)
                        .fillMaxWidth()
                ) {
                    // distance between each x point
                    val distance = size.width / (data.size + 1)
                    var currentX = 0F
//                    val maxValue = data.maxOrNull() ?: 0
                    val maxValue = 100
                    val points = mutableListOf<PointF>()

                    data.forEachIndexed { index, currentData ->
                        if (data.size >= index + 2) {
                            val y0 = (maxValue - currentData) * (size.height / maxValue)
                            val x0 = currentX + distance
                            points.add(PointF(x0, y0))
                            currentX += distance
                        }
                    }

                    if (style == LinearChartStyle.Default) {
                        for (i in 0 until points.size - 1) {
                            drawLine(
                                start = Offset(points[i].x, points[i].y),
                                end = Offset(points[i + 1].x, points[i + 1].y),
                                color = lineColor,
                                strokeWidth = 8f
                            )
                        }
                    } else {
                        val cubicPoints1 = mutableListOf<PointF>()
                        val cubicPoints2 = mutableListOf<PointF>()

                        for (i in 1 until points.size) {
                            cubicPoints1.add(
                                PointF(
                                    (points[i].x + points[i - 1].x) / 2,
                                    points[i - 1].y
                                )
                            )
                            cubicPoints2.add(
                                PointF(
                                    (points[i].x + points[i - 1].x) / 2,
                                    points[i].y
                                )
                            )
                        }

                        val path = Path()
                        path.moveTo(points.first().x, points.first().y)

                        for (i in 1 until points.size) {
                            path.cubicTo(
                                cubicPoints1[i - 1].x,
                                cubicPoints1[i - 1].y,
                                cubicPoints2[i - 1].x,
                                cubicPoints2[i - 1].y,
                                points[i].x,
                                points[i].y
                            )
                        }

                        drawPath(path, color = lineColor, style = Stroke(width = 8f))
                    }
                }
                Divider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f))
            }
        }
    }
}

private fun provideMockData() = listOf(
    5929, 6898, 8961, 5674, 7122, 6592, 3427, 5520, 4680, 7418,
    4743, 4080, 3611, 7295, 9900, 12438, 11186, 5439, 4227, 5138,
    11115, 8386, 12450, 10411, 10852, 7782, 7371, 4983, 9234, 6847
)

@Composable
fun ParkingAreaPastOccupancyChart(modifier: Modifier = Modifier, occupancy: List<Occupancy>) {

    LinearChart(
        modifier = modifier
            .fillMaxWidth(),
//            .padding(16.dp),
        height = 150.dp,
        data = occupancy.map { (it.occupancyRate * 100).toInt() },
        style = LinearChartStyle.Smooth
    )

}

@Preview(showBackground = true)
@Composable
private fun ParkingAreaPastOccupancyChartPreview() {
    MeinMoersTheme {
        ParkingAreaPastOccupancyChart(occupancy = listOf())
    }
}