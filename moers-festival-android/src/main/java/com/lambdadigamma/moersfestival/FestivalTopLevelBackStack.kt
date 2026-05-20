package com.lambdadigamma.moersfestival

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshots.SnapshotStateList
import androidx.compose.runtime.toMutableStateList

@Composable
fun rememberFestivalTopLevelBackStack(
    startKey: FestivalNavKey = FestivalNavKey.Timetable,
): FestivalTopLevelBackStack {
    val topLevelKeys = FestivalTopLevelNavKeys.toSet()
    return rememberSaveable(
        startKey,
        saver = festivalTopLevelBackStackSaver(
            startKey = startKey,
            topLevelKeys = topLevelKeys,
        ),
    ) {
        FestivalTopLevelBackStack(
            startKey = startKey,
            topLevelKeys = topLevelKeys,
        )
    }
}

class FestivalTopLevelBackStack internal constructor(
    private val startKey: FestivalNavKey,
    private val topLevelKeys: Set<FestivalNavKey>,
    restoredState: FestivalTopLevelBackStackState? = null,
) {
    private val restoredState = restoredState.takeIf {
        it?.startKey == startKey && startKey in topLevelKeys
    }

    private val topLevelStacks = this.restoredState
        ?.toValidatedStacks()
        ?: linkedMapOf(startKey to mutableStateListOf(startKey))

    var topLevelKey by mutableStateOf(
        this.restoredState
            ?.topLevelKey
            ?.takeIf { it in topLevelKeys && it in topLevelStacks }
            ?: startKey,
    )
        private set

    val backStack: SnapshotStateList<FestivalNavKey> = mutableStateListOf()

    init {
        if (startKey !in topLevelStacks) {
            topLevelStacks[startKey] = mutableStateListOf(startKey)
        }
        updateBackStack()
    }

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

    internal fun toSaveState(): FestivalTopLevelBackStackState {
        return FestivalTopLevelBackStackState(
            startKey = startKey,
            topLevelKey = topLevelKey,
            topLevelStacks = topLevelStacks.map { (key, stack) ->
                FestivalTopLevelStackState(
                    key = key,
                    stack = stack.toList(),
                )
            },
        )
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

    private fun FestivalTopLevelBackStackState.toValidatedStacks():
        LinkedHashMap<FestivalNavKey, SnapshotStateList<FestivalNavKey>> {
        val restoredStacks = linkedMapOf<FestivalNavKey, SnapshotStateList<FestivalNavKey>>()

        topLevelStacks.forEach { stackState ->
            val key = stackState.key
            if (key !in topLevelKeys) return@forEach

            val stack = stackState.stack.validatedForTopLevelKey(key) ?: return@forEach
            restoredStacks[key] = stack.toMutableStateList()
        }

        if (startKey !in restoredStacks) {
            restoredStacks[startKey] = mutableStateListOf(startKey)
        }

        return restoredStacks
    }

    private fun List<FestivalNavKey>.validatedForTopLevelKey(
        key: FestivalNavKey,
    ): List<FestivalNavKey>? {
        if (isEmpty()) return listOf(key)
        if (first() != key) return null
        if (drop(1).any { it in topLevelKeys }) return null

        return this
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
