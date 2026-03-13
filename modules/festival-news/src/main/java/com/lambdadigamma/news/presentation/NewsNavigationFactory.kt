package com.lambdadigamma.news.presentation

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavType
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import androidx.navigation.navDeepLink
import com.lambdadigamma.core.navigation.NavigationCommand
import com.lambdadigamma.core.navigation.NavigationDestination
import com.lambdadigamma.core.navigation.NavigationFactory
import com.lambdadigamma.core.navigation.NavigationManager
import com.lambdadigamma.news.presentation.detail.PostDetailRoute
import com.lambdadigamma.news.presentation.list.NewsListRoute
import javax.inject.Inject

@OptIn(ExperimentalFoundationApi::class)
class NewsNavigationFactory @Inject constructor() : NavigationFactory {

    @Inject
    lateinit var navigationManager: NavigationManager

    override fun create(builder: NavGraphBuilder) {
        builder.composable(
            route = NavigationDestination.News.route,
            deepLinks = listOf(
                navDeepLink { uriPattern = "moersfestival://posts" }
            )
        ) {
            NewsListRoute(onShowPost = { id ->
                val command = object : NavigationCommand {
                    override val destination = NavigationDestination.NewsDetail.route.replace("{postId}", id.toString())
                }
                navigationManager.navigate(command)
            })
        }
        builder.composable(
            NavigationDestination.NewsDetail.route,
            arguments = listOf(navArgument("postId") { type = NavType.IntType }),
            deepLinks = listOf(
                navDeepLink { uriPattern = "moersfestival://posts/{postId}" }
            )
        ) {
            PostDetailRoute(onBack = {
                navigationManager.navigateBack()
            })
        }
    }
}
