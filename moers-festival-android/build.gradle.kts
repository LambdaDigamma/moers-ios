@file:Suppress("UnstableApiUsage")

import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    alias(libs.plugins.detekt)
    alias(libs.plugins.firebase.crashlytics)
    alias(libs.plugins.google.services)
    id("dagger.hilt.android.plugin")
    id("org.jetbrains.kotlin.android")
    alias(libs.plugins.ksp)
    alias(libs.plugins.composeCompiler)
    id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin")
}

val versionPropertiesFile = project.file("version.properties")
fun getCurrentVersionProperties(): Properties {
    return Properties().apply {
        load(FileInputStream(versionPropertiesFile))
    }
}

object Keys {
    const val VERSION_NAME = "VERSION_NAME"
    const val VERSION_CODE = "VERSION_CODE"
}

val versionProperties = getCurrentVersionProperties()

android {
    compileSdk = 36
    namespace = "com.lambdadigamma.moersfestival"

    defaultConfig {
        applicationId = "com.lambdadigamma.moersfestival"
        minSdk = 24
        targetSdk = 35
        versionCode = versionProperties[Keys.VERSION_CODE].toString().toInt()
        versionName = versionProperties[Keys.VERSION_NAME].toString()
    }

    buildFeatures {
        buildConfig = true
        compose = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
            // TODO: for development purposes, remember to create a release signing config when releasing proper app
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
//        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    composeOptions {
        kotlinCompilerExtensionVersion = libs.versions.compose.compiler.get()
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }
    packaging {
        resources.excludes.add("/META-INF/{AL2.0,LGPL2.1}")
    }
}

dependencies {
    implementation(project(":modules:core"))
    implementation(project(":modules:festival-events"))
    implementation(project(":modules:medialibrary"))
    implementation(project(":modules:pages"))
    implementation(project(":modules:festival-map"))
    implementation(project(":modules:festival-news"))

    implementation(platform(libs.compose.bom))

    implementation(libs.hilt)
    implementation(libs.navigation) // needed for Room
    implementation(libs.room.ktx)
    implementation(libs.timber)
    implementation(libs.compose.ui.preview)
    implementation(libs.compose.runtime.livedata)
    implementation(libs.compose.material3)
    implementation(libs.compose.icons)
    implementation(libs.accompanist.systemuicontroller)
    implementation(libs.compose.webview)
    implementation(libs.core.ktx)
    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.android)

    implementation(libs.activity.ktx)

    implementation(platform(libs.firebase.platform))
    implementation(libs.firebase.analytics)
    implementation(libs.firebase.messaging)
    implementation(libs.firebase.crashlytics)

    ksp(libs.hilt.compiler)
    ksp(libs.room.compiler)

//    coreLibraryDesugaring(libs.desugar)

    detektPlugins(libs.detekt.compose.rules)
}

ksp {
    arg("room.schemaLocation", "$projectDir/schemas")
}

secrets {
    // To add your Maps API key to this project:
    // 1. Add this line to your local.properties file, where YOUR_API_KEY is your API key:
    //        FESTIVAL_MAPS_API_KEY=YOUR_API_KEY
    defaultPropertiesFileName = "local.defaults.properties"
}

tasks.create("incrementVersion") {
    group = "versioning"
    description = "Increments the version to make the app ready for next release."
    doLast {

        val versionProperties = getCurrentVersionProperties()
        val versionName = versionProperties.getProperty(Keys.VERSION_NAME)
        val mode = project.properties["mode"]?.toString()?.lowercase()

        var (major, minor, patch) = versionName.split(".")

        when (mode) {
            "major" -> {
                major = (major.toInt() + 1).toString()
                minor = "0"
                patch = "0"
            }
            "minor" -> {
                minor = (minor.toInt() + 1).toString()
                patch = "0"
            }
            else -> {
                patch = (patch.toInt() + 1).toString()
            }
        }
        var newVersion = "$major.$minor.$patch"

        val overrideVersion =
            project.properties["overrideVersion"]?.toString()?.lowercase()
        overrideVersion?.let { newVersion = it }

        versionProperties.setProperty(Keys.VERSION_NAME, newVersion)
        versionProperties.store(versionPropertiesFile.writer(), null)

    }
}

tasks.create("incrementVersionCode") {
    group = "versioning"
    description = "Increments the version code."
    doLast {

        val versionProperties = getCurrentVersionProperties()
        val currentVersionCode = versionProperties[Keys.VERSION_CODE].toString().toInt()
        versionProperties.setProperty(Keys.VERSION_CODE, (currentVersionCode + 1).toString())
        versionProperties.store(versionPropertiesFile.writer(), null)

    }
}
