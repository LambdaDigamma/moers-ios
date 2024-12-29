import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.kotlinxSerialization)
    alias(libs.plugins.ksp)
    alias(libs.plugins.kmpNativeCoroutines)
    alias(libs.plugins.composeCompiler)
}

kotlin {
    androidTarget {
        @OptIn(ExperimentalKotlinGradlePluginApi::class)
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }
    
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach {
        it.binaries.framework {
            baseName = "core"
            isStatic = true
        }
    }

    sourceSets {
        commonMain.dependencies {
            //put your multiplatform dependencies here
        }
        androidMain.dependencies {

            // Google Play Services
            implementation(libs.play.services.location)

            // Hilt
            implementation(libs.androidx.hilt.navigation.compose)

            // Retrofit
            implementation(libs.retrofit)
            implementation(libs.converter.simplexml)
            implementation(libs.converter.gson)
            implementation(libs.retrofit.mock)

            // Datastore
            implementation(libs.androidx.datastore)
            implementation(libs.androidx.datastore.preferences)

            // Compose
            implementation(libs.androidx.compose.ui)
            implementation(libs.androidx.material3)
            implementation(libs.androidx.compose.ui.tooling.preview)
            implementation(libs.androidx.compose.runtime.livedata)

            // Google Maps
            implementation(libs.maps.compose)
            implementation(libs.play.services.maps)

            implementation(libs.accompanist.swiperefresh)

        }
        commonTest.dependencies {
//            implementation(libs.kotlin.test)
        }
    }
}

android {
    namespace = "app.moers.core"
    compileSdk = libs.versions.compileSdk.get().toInt()
    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    buildFeatures {
        compose = true
    }
}
