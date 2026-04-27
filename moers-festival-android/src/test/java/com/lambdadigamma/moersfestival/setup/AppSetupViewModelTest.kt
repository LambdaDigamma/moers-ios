package com.lambdadigamma.moersfestival.setup

import com.lambdadigamma.moersfestival.notifications.FestivalNotificationManager
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class AppSetupViewModelTest {

    private val dispatcher = StandardTestDispatcher()

    private lateinit var repository: AppSetupRepository
    private lateinit var notificationManager: FestivalNotificationManager
    private lateinit var stateFlow: MutableStateFlow<AppSetupState>

    private var permissionGranted = false

    @BeforeEach
    fun setUp() {
        Dispatchers.setMain(dispatcher)

        stateFlow = MutableStateFlow(AppSetupState())
        repository = mockk(relaxed = true)
        notificationManager = mockk(relaxed = true)

        every { repository.observeState() } returns stateFlow
        every { notificationManager.hasNotificationPermission() } answers { permissionGranted }
        every { notificationManager.ensureDefaultNotificationChannel() } returns Unit
        every { notificationManager.openSystemNotificationSettings() } returns Unit
        coEvery { notificationManager.subscribeToGeneralTopic() } returns Result.success(Unit)
        coEvery { repository.setOnboardingCompleted(any()) } answers {
            stateFlow.value = stateFlow.value.copy(onboardingCompleted = firstArg())
            Unit
        }
        coEvery { repository.setDownloadPromptHandled(any()) } answers {
            stateFlow.value = stateFlow.value.copy(downloadPromptHandled = firstArg())
            Unit
        }
        coEvery { repository.setNotificationPermissionRequested(any()) } answers {
            stateFlow.value = stateFlow.value.copy(notificationPermissionRequested = firstArg())
            Unit
        }
        coEvery { repository.setNotificationTopicSubscribed(any()) } answers {
            stateFlow.value = stateFlow.value.copy(notificationTopicSubscribed = firstArg())
            Unit
        }
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `should transition from onboarding to download prompt`() = runTest(dispatcher) {
        permissionGranted = false
        val objectUnderTest = AppSetupViewModel(repository, notificationManager)
        advanceUntilIdle()

        assertTrue(objectUnderTest.uiState.value.shouldShowOnboarding)
        assertFalse(objectUnderTest.uiState.value.shouldShowDownloadPrompt)

        objectUnderTest.completeOnboarding()
        advanceUntilIdle()

        assertFalse(objectUnderTest.uiState.value.shouldShowOnboarding)
        assertTrue(objectUnderTest.uiState.value.shouldShowDownloadPrompt)

        objectUnderTest.markDownloadPromptHandled()
        advanceUntilIdle()

        assertFalse(objectUnderTest.uiState.value.shouldShowDownloadPrompt)
        verify(exactly = 1) { notificationManager.ensureDefaultNotificationChannel() }
        coVerify(exactly = 0) { notificationManager.subscribeToGeneralTopic() }
    }

    @Test
    fun `should subscribe to topic when permission is already granted`() = runTest(dispatcher) {
        permissionGranted = true
        val objectUnderTest = AppSetupViewModel(repository, notificationManager)
        advanceUntilIdle()

        assertTrue(objectUnderTest.uiState.value.notificationPermissionGranted)
        assertTrue(objectUnderTest.uiState.value.notificationTopicSubscribed)
        assertFalse(objectUnderTest.uiState.value.isSyncingNotifications)

        coVerify(exactly = 1) { notificationManager.subscribeToGeneralTopic() }
    }

    @Test
    fun `should subscribe after notification permission becomes available`() = runTest(dispatcher) {
        permissionGranted = false
        val objectUnderTest = AppSetupViewModel(repository, notificationManager)
        advanceUntilIdle()

        coVerify(exactly = 0) { notificationManager.subscribeToGeneralTopic() }

        permissionGranted = true
        objectUnderTest.refreshNotificationState()
        advanceUntilIdle()

        assertTrue(objectUnderTest.uiState.value.notificationPermissionGranted)
        assertTrue(objectUnderTest.uiState.value.notificationTopicSubscribed)
        assertFalse(objectUnderTest.uiState.value.isSyncingNotifications)
        coVerify(exactly = 1) { notificationManager.subscribeToGeneralTopic() }
    }
}
