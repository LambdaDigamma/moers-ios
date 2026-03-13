@file:Suppress("UnstableApiUsage")

include(":news")


include(":map")


include(":prosemirror")


include(":medialibrary")
include(":core")
include(":app")
include(":events")
include(":pages")

pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.10.0"
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
