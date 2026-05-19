package com.lambdadigamma.moersfestival

import android.Manifest.permission.POST_NOTIFICATIONS
import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.navigation3.rememberViewModelStoreNavEntryDecorator
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberSaveableStateHolderNavEntryDecorator
import androidx.navigation3.ui.NavDisplay
import com.lambdadigamma.core.ui.MoersFestivalTheme
import com.lambdadigamma.events.presentation.detail.composable.EventDetailRoute
import com.lambdadigamma.events.presentation.download.DownloadEventsRoute
import com.lambdadigamma.events.presentation.favorites.composable.FavoriteEventsRoute
import com.lambdadigamma.events.presentation.timetable.composable.TimetableRoute
import com.lambdadigamma.events.presentation.venue.composable.VenueDetailRoute
import com.lambdadigamma.map.presentation.composable.MapRoute
import com.lambdadigamma.moersfestival.setup.AppSetupViewModel
import com.lambdadigamma.moersfestival.setup.FestivalOnboardingScreen
import com.lambdadigamma.moersfestival.setup.NotificationSettingsRoute
import com.lambdadigamma.moersfestival.ui.AppInformationRoute
import com.lambdadigamma.moersfestival.ui.AppTab
import com.lambdadigamma.moersfestival.ui.BottomBar
import com.lambdadigamma.moersfestival.ui.LicensesRoute
import com.lambdadigamma.news.presentation.detail.PostDetailRoute
import com.lambdadigamma.news.presentation.list.NewsListRoute

@Composable
fun App(
    incomingIntent: android.content.Intent?,
    onIncomingIntentConsumed: () -> Unit,
) {
    val setupViewModel: AppSetupViewModel = hiltViewModel()
    val setupUiState by setupViewModel.uiState.collectAsStateWithLifecycle()
    val lifecycleOwner = LocalLifecycleOwner.current
    var pendingStack by remember { mutableStateOf<List<FestivalNavKey>?>(null) }
    var showFirstRunDownloadFinish by remember { mutableStateOf(false) }
    val firstRunDownloadStack = remember {
        listOf(FestivalNavKey.Timetable, FestivalNavKey.DownloadEvents)
    }

    fun finishOnboarding() {
        if (pendingStack == null) {
            pendingStack = firstRunDownloadStack
            showFirstRunDownloadFinish = true
        }
        setupViewModel.markDownloadPromptHandled()
        setupViewModel.completeOnboarding()
    }

    val notificationPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission(),
    ) {
        setupViewModel.refreshNotificationState()
        finishOnboarding()
    }

    DisposableEffect(lifecycleOwner, setupViewModel) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) {
                setupViewModel.refreshNotificationState()
            }
        }

        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    LaunchedEffect(incomingIntent) {
        incomingIntent
            ?.resolveFestivalStack()
            ?.let { stack -> pendingStack = stack }

        if (incomingIntent != null) {
            onIncomingIntentConsumed()
        }
    }

    LaunchedEffect(setupUiState.shouldShowDownloadPrompt) {
        if (setupUiState.shouldShowDownloadPrompt) {
            if (pendingStack == null) {
                pendingStack = firstRunDownloadStack
                showFirstRunDownloadFinish = true
            }
            setupViewModel.markDownloadPromptHandled()
        }
    }

    MoersFestivalTheme {
        when {
            setupUiState.shouldShowOnboarding -> {
                FestivalOnboardingScreen(
                    notificationPermissionGranted = setupUiState.notificationPermissionGranted,
                    onEnableNotifications = {
                        if (setupUiState.notificationPermissionGranted ||
                            Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU
                        ) {
                            setupViewModel.refreshNotificationState()
                            finishOnboarding()
                        } else {
                            setupViewModel.markNotificationPermissionRequested()
                            notificationPermissionLauncher.launch(POST_NOTIFICATIONS)
                        }
                    },
                    onSkipNotifications = {
                        finishOnboarding()
                    },
                )
            }

            else -> {
                MainAppShell(
                    pendingStack = if (setupUiState.shouldShowDownloadPrompt) {
                        pendingStack ?: firstRunDownloadStack
                    } else {
                        pendingStack
                    },
                    showFirstRunDownloadFinish = showFirstRunDownloadFinish,
                    showNotificationOptInBanner = !setupUiState.notificationPermissionGranted,
                    onPendingStackConsumed = {
                        pendingStack = null
                    },
                    onFirstRunDownloadFinished = {
                        showFirstRunDownloadFinish = false
                    },
                )
            }
        }
    }
}

@Composable
private fun MainAppShell(
    pendingStack: List<FestivalNavKey>?,
    showFirstRunDownloadFinish: Boolean,
    showNotificationOptInBanner: Boolean,
    onPendingStackConsumed: () -> Unit,
    onFirstRunDownloadFinished: () -> Unit,
) {
    val topLevelBackStack = rememberFestivalTopLevelBackStack()
    val navigator = remember(topLevelBackStack) { FestivalNavigator(topLevelBackStack) }

    LaunchedEffect(pendingStack) {
        pendingStack?.let { stack ->
            navigator.replaceWithSyntheticStack(stack)
            onPendingStackConsumed()
        }
    }

    val currentKey = topLevelBackStack.backStack.lastOrNull() ?: FestivalNavKey.Timetable
    val showBottomBar = currentKey in FestivalTopLevelNavKeys

    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                BottomBar(
                    currentTopLevelKey = topLevelBackStack.topLevelKey,
                    tabs = AppTab.entries.toTypedArray(),
                    onTabSelected = navigator::navigate,
                )
            }
        },
    ) { padding ->
        val bottomPadding = if (showBottomBar) {
            padding.calculateBottomPadding()
        } else {
            0.dp
        }

        NavDisplay(
            modifier = Modifier.padding(bottom = bottomPadding),
            backStack = topLevelBackStack.backStack,
            onBack = {
                if (currentKey == FestivalNavKey.DownloadEvents && showFirstRunDownloadFinish) {
                    onFirstRunDownloadFinished()
                }
                topLevelBackStack.removeLast()
            },
            entryDecorators = listOf(
                rememberSaveableStateHolderNavEntryDecorator(),
                rememberViewModelStoreNavEntryDecorator(),
            ),
            entryProvider = entryProvider {
                entry<FestivalNavKey.News> {
                    NewsListRoute(
                        onShowPost = { postId ->
                            navigator.navigate(FestivalNavKey.NewsDetail(postId))
                        },
                        onShowUrl = { url ->
                            navigator.navigate(FestivalNavKey.Web(url))
                        },
                    )
                }

                entry<FestivalNavKey.Map> {
                    MapRoute(
                        onShowEvent = { eventId ->
                            navigator.navigate(FestivalNavKey.EventDetail(eventId))
                        },
                    )
                }

                entry<FestivalNavKey.Favorites> {
                    FavoriteEventsRoute(
                        onShowEvent = { eventId ->
                            navigator.navigate(FestivalNavKey.EventDetail(eventId))
                        },
                        onShowTimetable = {
                            navigator.replaceWithSyntheticStack(listOf(FestivalNavKey.Timetable))
                        },
                    )
                }

                entry<FestivalNavKey.Timetable> {
                    TimetableRoute(
                        onShowEvent = { eventId ->
                            navigator.navigate(FestivalNavKey.EventDetail(eventId))
                        },
                        onShowDownload = {
                            navigator.navigate(FestivalNavKey.DownloadEvents)
                        },
                    )
                }

                entry<FestivalNavKey.Info> {
                    InfoScreen(
                        onOpenWeb = { url -> navigator.navigate(FestivalNavKey.Web(url)) },
                        onOpenDownload = { navigator.navigate(FestivalNavKey.DownloadEvents) },
                        onOpenNotificationSettings = {
                            navigator.navigate(FestivalNavKey.NotificationSettings)
                        },
                        onOpenAppInformation = {
                            navigator.navigate(FestivalNavKey.AppInformation)
                        },
                        onOpenLicenses = {
                            navigator.navigate(FestivalNavKey.Licenses)
                        },
                        showNotificationOptInBanner = showNotificationOptInBanner,
                    )
                }

                entry<FestivalNavKey.NewsDetail> { key ->
                    PostDetailRoute(
                        postId = key.postId,
                        onBack = navigator::navigateBack,
                    )
                }

                entry<FestivalNavKey.EventDetail> { key ->
                    EventDetailRoute(
                        eventId = key.eventId,
                        onBack = navigator::navigateBack,
                        onShowVenue = { placeId ->
                            navigator.navigate(FestivalNavKey.VenueDetail(placeId))
                        },
                    )
                }

                entry<FestivalNavKey.VenueDetail> { key ->
                    VenueDetailRoute(
                        placeId = key.placeId,
                        onBack = navigator::navigateBack,
                        onShowEvent = { eventId ->
                            navigator.navigate(FestivalNavKey.EventDetail(eventId))
                        },
                    )
                }

                entry<FestivalNavKey.DownloadEvents> {
                    DownloadEventsRoute(
                        onBack = {
                            if (showFirstRunDownloadFinish) {
                                onFirstRunDownloadFinished()
                            }
                            navigator.navigateBack()
                        },
                        onFinish = if (showFirstRunDownloadFinish) {
                            {
                                onFirstRunDownloadFinished()
                                navigator.replaceWithSyntheticStack(listOf(FestivalNavKey.Timetable))
                            }
                        } else {
                            null
                        },
                    )
                }

                entry<FestivalNavKey.Web> { key ->
                    WebViewScreen(
                        url = key.url,
                        onBack = navigator::navigateBack,
                    )
                }

                entry<FestivalNavKey.AppInformation> {
                    AppInformationRoute(onBack = navigator::navigateBack)
                }

                entry<FestivalNavKey.Licenses> {
                    LicensesRoute(onBack = navigator::navigateBack)
                }

                entry<FestivalNavKey.NotificationSettings> {
                    NotificationSettingsRoute(onBack = navigator::navigateBack)
                }
            },
        )
    }
}
