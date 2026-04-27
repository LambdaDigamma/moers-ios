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
}
