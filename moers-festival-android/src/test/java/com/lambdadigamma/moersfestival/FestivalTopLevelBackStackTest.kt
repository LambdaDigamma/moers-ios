package com.lambdadigamma.moersfestival

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

class FestivalTopLevelBackStackTest {

    @Test
    fun `should preserve tab stacks when switching top level destinations`() {
        val backStack = FestivalTopLevelBackStack(
            startKey = FestivalNavKey.Timetable,
            topLevelKeys = FestivalTopLevelNavKeys.toSet(),
        )

        backStack.navigate(FestivalNavKey.EventDetail(7))
        backStack.navigate(FestivalNavKey.News)
        backStack.navigate(FestivalNavKey.NewsDetail(11))
        backStack.navigate(FestivalNavKey.Timetable)

        assertEquals(FestivalNavKey.Timetable, backStack.topLevelKey)
        assertEquals(
            listOf(FestivalNavKey.Timetable, FestivalNavKey.EventDetail(7)),
            backStack.backStack.toList(),
        )

        backStack.navigate(FestivalNavKey.News)

        assertEquals(
            listOf(
                FestivalNavKey.Timetable,
                FestivalNavKey.EventDetail(7),
                FestivalNavKey.News,
                FestivalNavKey.NewsDetail(11),
            ),
            backStack.backStack.toList(),
        )
    }

    @Test
    fun `should replace current tab with synthetic deep link stack`() {
        val backStack = FestivalTopLevelBackStack(
            startKey = FestivalNavKey.Timetable,
            topLevelKeys = FestivalTopLevelNavKeys.toSet(),
        )

        backStack.replaceWithSyntheticStack(
            listOf(FestivalNavKey.News, FestivalNavKey.NewsDetail(42)),
        )

        assertEquals(FestivalNavKey.News, backStack.topLevelKey)
        assertEquals(
            listOf(FestivalNavKey.Timetable, FestivalNavKey.News, FestivalNavKey.NewsDetail(42)),
            backStack.backStack.toList(),
        )
    }

    @Test
    fun `should restore selected top level destination`() {
        val restored = FestivalTopLevelBackStack(
            startKey = FestivalNavKey.Timetable,
            topLevelKeys = FestivalTopLevelNavKeys.toSet(),
        ).run {
            navigate(FestivalNavKey.Map)
            restoreFromSavedState(encodeAsSavedState())
        }

        assertEquals(FestivalNavKey.Map, restored.topLevelKey)
        assertEquals(
            listOf(FestivalNavKey.Timetable, FestivalNavKey.Map),
            restored.backStack.toList(),
        )
    }

    @Test
    fun `should restore nested stack for current tab`() {
        val restored = FestivalTopLevelBackStack(
            startKey = FestivalNavKey.Timetable,
            topLevelKeys = FestivalTopLevelNavKeys.toSet(),
        ).run {
            navigate(FestivalNavKey.EventDetail(7))
            restoreFromSavedState(encodeAsSavedState())
        }

        assertEquals(FestivalNavKey.Timetable, restored.topLevelKey)
        assertEquals(
            listOf(FestivalNavKey.Timetable, FestivalNavKey.EventDetail(7)),
            restored.backStack.toList(),
        )
    }

    @Test
    fun `should restore per-tab stacks`() {
        val restored = FestivalTopLevelBackStack(
            startKey = FestivalNavKey.Timetable,
            topLevelKeys = FestivalTopLevelNavKeys.toSet(),
        ).run {
            navigate(FestivalNavKey.EventDetail(7))
            navigate(FestivalNavKey.News)
            navigate(FestivalNavKey.NewsDetail(11))
            navigate(FestivalNavKey.Favorites)
            navigate(FestivalNavKey.EventDetail(13))
            restoreFromSavedState(encodeAsSavedState())
        }

        assertEquals(FestivalNavKey.Favorites, restored.topLevelKey)
        assertEquals(
            listOf(
                FestivalNavKey.Timetable,
                FestivalNavKey.EventDetail(7),
                FestivalNavKey.Favorites,
                FestivalNavKey.EventDetail(13),
            ),
            restored.backStack.toList(),
        )

        restored.navigate(FestivalNavKey.News)

        assertEquals(
            listOf(
                FestivalNavKey.Timetable,
                FestivalNavKey.EventDetail(7),
                FestivalNavKey.News,
                FestivalNavKey.NewsDetail(11),
            ),
            restored.backStack.toList(),
        )
    }

    @Test
    fun `should restore synthetic download stack`() {
        val restored = FestivalTopLevelBackStack(
            startKey = FestivalNavKey.Timetable,
            topLevelKeys = FestivalTopLevelNavKeys.toSet(),
        ).run {
            replaceWithSyntheticStack(
                listOf(FestivalNavKey.Timetable, FestivalNavKey.DownloadEvents),
            )
            restoreFromSavedState(encodeAsSavedState())
        }

        assertEquals(FestivalNavKey.Timetable, restored.topLevelKey)
        assertEquals(
            listOf(FestivalNavKey.Timetable, FestivalNavKey.DownloadEvents),
            restored.backStack.toList(),
        )
    }

    @Test
    fun `should fall back to start destination when saved state is invalid`() {
        val restored = restoreFromSavedState("not-json")

        assertEquals(FestivalNavKey.Timetable, restored.topLevelKey)
        assertEquals(listOf(FestivalNavKey.Timetable), restored.backStack.toList())
    }

    private fun restoreFromSavedState(
        savedState: String,
    ): FestivalTopLevelBackStack {
        return restoreFestivalTopLevelBackStackFromSavedState(
            savedState = savedState,
            startKey = FestivalNavKey.Timetable,
            topLevelKeys = FestivalTopLevelNavKeys.toSet(),
        )
    }
}
