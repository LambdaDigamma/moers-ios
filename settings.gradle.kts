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
    }
    plugins {
        kotlin("jvm") version "2.4.21"
    }
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
include(":modules:medialibrary")
include(":modules:festival-news")
include(":modules:pages")
include(":modules:prosemirror")

include(":moers-android")
project(":moers-android").projectDir = file("moers-android")
include(":moers-festival-android")
project(":moers-festival-android").projectDir = file("moers-festival-android")
