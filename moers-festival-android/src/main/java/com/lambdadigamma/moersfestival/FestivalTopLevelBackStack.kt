package com.lambdadigamma.moersfestival

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshots.SnapshotStateList
import androidx.compose.runtime.toMutableStateList

@Composable
fun rememberFestivalTopLevelBackStack(
    startKey: FestivalNavKey = FestivalNavKey.Timetable,
): FestivalTopLevelBackStack {
    return remember(startKey) {
        FestivalTopLevelBackStack(
            startKey = startKey,
            topLevelKeys = FestivalTopLevelNavKeys.toSet(),
        )
    }
}
class FestivalTopLevelBackStack(
    private val startKey: FestivalNavKey,
    private val topLevelKeys: Set<FestivalNavKey>,
) {
    private val topLevelStacks = linkedMapOf(
        startKey to mutableStateListOf(startKey),
    )

    var topLevelKey by mutableStateOf(startKey)
        private set

    val backStack: SnapshotStateList<FestivalNavKey> = mutableStateListOf(startKey)

    fun navigate(key: FestivalNavKey) {
        if (key in topLevelKeys) {
            selectTopLevel(key)
            return
        }

        val stack = topLevelStacks.getOrPut(topLevelKey) {
            mutableStateListOf(topLevelKey)
        }
        stack.add(key)
        updateBackStack()
    }

    fun selectTopLevel(key: FestivalNavKey) {
        require(key in topLevelKeys) { "$key is not a top-level festival destination." }

        if (!topLevelStacks.containsKey(key)) {
            topLevelStacks[key] = mutableStateListOf(key)
        }

        topLevelKey = key
        updateBackStack()
    }

    fun replaceWithSyntheticStack(stack: List<FestivalNavKey>) {
        val topLevelKey = stack.firstOrNull()?.topLevelKey() ?: startKey
        require(topLevelKey in topLevelKeys) {
            "$topLevelKey is not a top-level festival destination."
        }

        topLevelStacks[topLevelKey] = stack
            .ifEmpty { listOf(topLevelKey) }
            .toMutableStateList()
        this.topLevelKey = topLevelKey
        updateBackStack()
    }

    fun removeLast(): Boolean {
        val currentStack = topLevelStacks[topLevelKey] ?: return false

        if (currentStack.size > 1) {
            currentStack.removeAt(currentStack.lastIndex)
            updateBackStack()
            return true
        }

        if (topLevelKey != startKey) {
            topLevelKey = startKey
            updateBackStack()
            return true
        }

        return false
    }

    private fun updateBackStack() {
        val startStack = topLevelStacks[startKey] ?: mutableStateListOf(startKey)
        val currentStack = topLevelStacks[topLevelKey] ?: mutableStateListOf(topLevelKey)

        backStack.clear()
        backStack.addAll(startStack)

        if (topLevelKey != startKey) {
            backStack.addAll(currentStack)
        }
    }
}

class FestivalNavigator(
    private val backStack: FestivalTopLevelBackStack,
) {
    fun navigate(key: FestivalNavKey) {
        backStack.navigate(key)
    }

    fun replaceWithSyntheticStack(stack: List<FestivalNavKey>) {
        backStack.replaceWithSyntheticStack(stack)
    }

    fun navigateBack() {
        backStack.removeLast()
    }
}
