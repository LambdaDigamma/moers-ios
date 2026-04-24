package com.lambdadigamma.moersfestival.setup

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.CalendarMonth
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material.icons.rounded.DownloadForOffline
import androidx.compose.material.icons.rounded.Newspaper
import androidx.compose.material.icons.rounded.NotificationsActive
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun FestivalOnboardingScreen(
    notificationPermissionGranted: Boolean,
    onEnableNotifications: () -> Unit,
    onSkipNotifications: () -> Unit,
) {
    var page by rememberSaveable { mutableIntStateOf(0) }

    val colors = MaterialTheme.colorScheme
    val scrollState = rememberScrollState()
    val showTopScrollEdge by remember {
        derivedStateOf { scrollState.value > 0 }
    }
    val showBottomScrollEdge by remember {
        derivedStateOf { scrollState.value < scrollState.maxValue }
    }

    LaunchedEffect(page) {
        scrollState.scrollTo(0)
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(colors.background)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = 24.dp)
            .padding(top = 8.dp, bottom = 16.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
        ) {
            StepIndicator(
                currentPage = page + 1,
                pageCount = 2,
            )

            Spacer(modifier = Modifier.height(18.dp))

            Box(
                modifier = Modifier.weight(1f),
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(scrollState),
                ) {
                    if (page == 0) {
                        OnboardingPageCard(
                            modifier = Modifier.padding(vertical = 2.dp),
                            primaryIcon = Icons.Rounded.CalendarMonth,
                            secondaryIcon = Icons.Rounded.Newspaper,
                            tertiaryIcon = Icons.Rounded.DownloadForOffline,
                            eyebrow = stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_welcome_eyebrow),
                            title = stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_welcome_title),
                            body = stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_welcome_description),
                        ) {
                            OnboardingFeatureItem(
                                icon = Icons.Rounded.Newspaper,
                                label = stringResource(com.lambdadigamma.moersfestival.R.string.navigation_news),
                            )
                            OnboardingFeatureItem(
                                icon = Icons.Rounded.CalendarMonth,
                                label = stringResource(com.lambdadigamma.moersfestival.R.string.navigation_events),
                            )
                            OnboardingFeatureItem(
                                icon = Icons.Rounded.DownloadForOffline,
                                label = stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_download_badge),
                            )
                        }
                    } else {
                        OnboardingPageCard(
                            modifier = Modifier.padding(vertical = 2.dp),
                            primaryIcon = Icons.Rounded.NotificationsActive,
                            secondaryIcon = Icons.Rounded.CalendarMonth,
                            tertiaryIcon = Icons.Rounded.Newspaper,
                            eyebrow = stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_notifications_kicker),
                            title = stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_notifications_title),
                            body = stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_notifications_description),
                        ) {
                            if (notificationPermissionGranted) {
                                OnboardingFeatureItem(
                                    icon = Icons.Rounded.CheckCircle,
                                    label = stringResource(com.lambdadigamma.moersfestival.R.string.notification_settings_status_enabled),
                                    emphasized = true,
                                )
                            } else {
                                OnboardingFeatureItem(
                                    icon = Icons.Rounded.NotificationsActive,
                                    label = stringResource(com.lambdadigamma.moersfestival.R.string.info_row_notifications_description),
                                )
                            }
                        }
                    }
                }

                ScrollEdgeFade(
                    visible = showTopScrollEdge,
                    alignment = Alignment.TopCenter,
                    colors = listOf(
                        colors.background,
                        colors.background.copy(alpha = 0f),
                    ),
                )

                ScrollEdgeFade(
                    visible = showBottomScrollEdge,
                    alignment = Alignment.BottomCenter,
                    colors = listOf(
                        colors.background.copy(alpha = 0f),
                        colors.background,
                    ),
                )
            }

            Spacer(modifier = Modifier.height(18.dp))

            Column {
                if (page == 0) {
                    Button(
                        onClick = { page = 1 },
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(min = 56.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = colors.primary,
                            contentColor = colors.onPrimary,
                        ),
                    ) {
                        Text(
                            text = stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_continue),
                            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold),
                        )
                    }
                } else {
                    Button(
                        onClick = onEnableNotifications,
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(min = 56.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = colors.primary,
                            contentColor = colors.onPrimary,
                        ),
                    ) {
                        Text(
                            text = if (notificationPermissionGranted) {
                                stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_continue)
                            } else {
                                stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_notifications_primary)
                            },
                            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold),
                        )
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    OutlinedButton(
                        onClick = onSkipNotifications,
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(min = 56.dp),
                        shape = RoundedCornerShape(16.dp),
                        border = BorderStroke(1.dp, colors.outlineVariant),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = colors.onBackground),
                    ) {
                        Text(
                            text = stringResource(com.lambdadigamma.moersfestival.R.string.onboarding_notifications_secondary),
                            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold),
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun BoxScope.ScrollEdgeFade(
    visible: Boolean,
    alignment: Alignment,
    colors: List<Color>,
    modifier: Modifier = Modifier,
) {
    val alpha by animateFloatAsState(
        targetValue = if (visible) 1f else 0f,
        label = "Onboarding scroll edge fade",
    )

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(18.dp)
            .align(alignment)
            .alpha(alpha)
            .background(Brush.verticalGradient(colors)),
    )
}

@Composable
private fun OnboardingPageCard(
    primaryIcon: ImageVector,
    secondaryIcon: ImageVector,
    tertiaryIcon: ImageVector,
    eyebrow: String,
    title: String,
    body: String,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit,
) {
    val colors = MaterialTheme.colorScheme

    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(24.dp),
        color = colors.surface,
        tonalElevation = 1.dp,
        shadowElevation = 1.dp,
    ) {
        Column(
            modifier = Modifier.padding(22.dp),
        ) {
            OnboardingIconStage(
                primaryIcon = primaryIcon,
                secondaryIcon = secondaryIcon,
                tertiaryIcon = tertiaryIcon,
            )

            Spacer(modifier = Modifier.height(22.dp))

            Text(
                text = eyebrow,
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
                color = colors.primary,
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = title,
                style = MaterialTheme.typography.headlineLarge.copy(
                    fontWeight = FontWeight.ExtraBold,
                    lineHeight = 38.sp,
                ),
                color = colors.onSurface,
            )

            Spacer(modifier = Modifier.height(14.dp))

            Text(
                text = body,
                style = MaterialTheme.typography.bodyLarge.copy(lineHeight = 25.sp),
                color = colors.onSurfaceVariant,
            )

            Spacer(modifier = Modifier.height(22.dp))

            Column(
                verticalArrangement = Arrangement.spacedBy(10.dp),
                content = content,
            )
        }
    }
}

@Composable
private fun OnboardingIconStage(
    primaryIcon: ImageVector,
    secondaryIcon: ImageVector,
    tertiaryIcon: ImageVector,
) {
    val colors = MaterialTheme.colorScheme

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(128.dp),
        color = colors.surfaceVariant.copy(alpha = 0.42f),
        shape = RoundedCornerShape(20.dp),
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            IconBubble(
                icon = secondaryIcon,
                tint = colors.tertiary,
                modifier = Modifier
                    .align(Alignment.TopStart)
                    .padding(start = 24.dp, top = 22.dp),
            )

            Surface(
                modifier = Modifier.align(Alignment.Center),
                shape = CircleShape,
                color = colors.surface,
                tonalElevation = 2.dp,
            ) {
                Icon(
                    imageVector = primaryIcon,
                    contentDescription = null,
                    tint = colors.primary,
                    modifier = Modifier
                        .padding(20.dp)
                        .size(42.dp),
                )
            }

            IconBubble(
                icon = tertiaryIcon,
                tint = colors.secondary,
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = 24.dp, bottom = 22.dp),
            )
        }
    }
}

@Composable
private fun IconBubble(
    icon: ImageVector,
    tint: Color,
    modifier: Modifier = Modifier,
) {
    val colors = MaterialTheme.colorScheme

    Surface(
        modifier = modifier,
        shape = CircleShape,
        color = colors.surface.copy(alpha = 0.9f),
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = tint,
            modifier = Modifier
                .padding(12.dp)
                .size(24.dp),
        )
    }
}

@Composable
private fun OnboardingFeatureItem(
    icon: ImageVector,
    label: String,
    emphasized: Boolean = false,
) {
    val colors = MaterialTheme.colorScheme
    val containerColor = colors.surfaceVariant.copy(alpha = 0.55f)
    val iconContainerColor = if (emphasized) {
        colors.primaryContainer
    } else {
        colors.surface
    }
    val iconTint = colors.primary
    val textColor = colors.onSurfaceVariant

    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = containerColor,
        shape = RoundedCornerShape(16.dp),
    ) {
        Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Surface(
                shape = CircleShape,
                color = iconContainerColor,
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = iconTint,
                    modifier = Modifier
                        .padding(8.dp)
                        .size(20.dp),
                )
            }

            Text(
                text = label,
                style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.SemiBold),
                color = textColor,
            )
        }
    }
}

@Composable
private fun StepIndicator(
    currentPage: Int,
    pageCount: Int,
    modifier: Modifier = Modifier,
) {
    val colors = MaterialTheme.colorScheme

    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(18.dp),
        color = colors.surface,
        tonalElevation = 1.dp,
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = stringResource(
                    com.lambdadigamma.moersfestival.R.string.onboarding_step_indicator,
                    currentPage,
                    pageCount,
                ),
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold),
                color = colors.onSurfaceVariant,
            )

            Spacer(modifier = Modifier.weight(1f))

            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                repeat(pageCount) { index ->
                    Box(
                        modifier = Modifier
                            .width(28.dp)
                            .height(6.dp)
                            .clip(CircleShape)
                            .background(
                                if (index < currentPage) {
                                    colors.primary
                                } else {
                                    colors.outlineVariant
                                }
                            ),
                    )
                }
            }
        }
    }
}
