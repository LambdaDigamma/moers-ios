@file:Suppress("UnstableApiUsage")

import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.library")
    alias(libs.plugins.detekt)
    id("dagger.hilt.android.plugin")
    alias(libs.plugins.junit)
    id("org.jetbrains.kotlin.android")
    alias(libs.plugins.ksp)
    id("org.jetbrains.kotlin.plugin.parcelize")
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.composeCompiler)
}

android {
    compileSdk = 36
    namespace = "com.lambdadigamma.core"

    with (defaultConfig) {
        minSdk = 24
        targetSdk = 35
    }

    defaultConfig {
        buildConfigField("String", "SPACEX_API_URL", "\"https://api.spacexdata.com/v4/\"")
    }

    buildFeatures {
        buildConfig = true
        compose = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            consumerProguardFiles("proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
//        isCoreLibraryDesugaringEnabled = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = libs.versions.compose.compiler.get()
    }

}

kotlin {
    compilerOptions {
        freeCompilerArgs.addAll(
            "-opt-in=androidx.compose.material3.ExperimentalMaterial3Api",
            "-opt-in=kotlinx.coroutines.FlowPreview",
            "-opt-in=kotlinx.coroutines.ExperimentalCoroutinesApi",
            "-opt-in=kotlinx.serialization.ExperimentalSerializationApi"
        )
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.material3)
    implementation(libs.hilt)
    implementation(libs.kotlin.coroutines)
    implementation(libs.kotlin.serialization)
    implementation(libs.kotlin.serialization.converter)
    implementation(libs.lifecycle.runtime.compose)
    implementation(libs.navigation)
    implementation(libs.okhttp.logging.interceptor)
    implementation(libs.retrofit)
    implementation(libs.timber)
    implementation(libs.gson)
    implementation(libs.retrofit.gson)
    implementation(libs.retrofit.mock)
    implementation(libs.gms.location)
    implementation(libs.gms.services)
    implementation(libs.maps.compose)
    implementation(libs.compose.ui.preview)
    implementation(libs.compose.runtime.livedata)
    implementation(libs.compose.icons)
    implementation(libs.accompanist.swipe.refresh)
    implementation(libs.accompanist.systemuicontroller)
    implementation(libs.datastore)
    implementation(libs.datastore.preferences)
    implementation(libs.room)
    implementation(libs.core.ktx)
    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.android)

    androidTestImplementation(libs.bundles.common.android.test)
    debugImplementation(libs.ui.tooling)

//    coreLibraryDesugaring(libs.desugar)

    ksp(libs.hilt.compiler)
    add("kspAndroidTest", libs.test.android.hilt.compiler)

    detektPlugins(libs.detekt.compose.rules)
}
