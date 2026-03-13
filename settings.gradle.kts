rootProject.name = "Moers"
enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

pluginManagement {
    repositories {
        google {
            mavenContent {
                includeGroupAndSubgroups("androidx")
                includeGroupAndSubgroups("com.android")
                includeGroupAndSubgroups("com.google")
            }
        }
        mavenCentral()
        gradlePluginPortal()
        maven("https://jitpack.io")
    }
    plugins {
        kotlin("jvm") version "2.2.21"
    }
}
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.8.0"
}

dependencyResolutionManagement {
    repositories {
        google {
            mavenContent {
                includeGroupAndSubgroups("androidx")
                includeGroupAndSubgroups("com.android")
                includeGroupAndSubgroups("com.google")
            }
        }
        mavenCentral()
        maven("https://jitpack.io")
    }
}

include(":modules:core")
include(":modules:news")
include(":modules:fuel")
include(":modules:events")
include(":modules:parking")
include(":modules:rubbish")
include(":modules:radio")
include(":modules:festival-events")
include(":modules:festival-map")
include(":modules:festival-medialibrary")
include(":modules:festival-news")
include(":modules:festival-pages")
include(":modules:prosemirror")

include(":moers-android")
project(":moers-android").projectDir = file("moers-android")
include(":moers-festival-android")
project(":moers-festival-android").projectDir = file("moers-festival-android")
