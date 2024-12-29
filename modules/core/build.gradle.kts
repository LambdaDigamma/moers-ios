import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.ksp)
    alias(libs.plugins.composeCompiler)
}

/**
 * Accessing the defined global versions using a type safe delegate.
 */
val sdkVersion: Int by rootProject.extra
val minSdkVersion: Int by rootProject.extra

kotlin {

    androidTarget {

        @OptIn(ExperimentalKotlinGradlePluginApi::class)
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }

    }

    iosX64()
    iosArm64()
    iosSimulatorArm64()

    sourceSets {
        androidMain.dependencies {
            implementation(libs.androidx.core.ktx)
            implementation(libs.androidx.appcompat)
            implementation(libs.material)

            implementation(libs.kotlinx.coroutines.android)

            // Google Play Services
            implementation(libs.play.services.location)
            implementation(libs.androidx.work.runtime.ktx)

            // Room Database
            implementation(libs.room.runtime)
            implementation(libs.room.ktx)
            implementation(libs.androidx.room.paging)

            // Hilt
            implementation(libs.hilt.android)
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
        androidUnitTest.dependencies {
            implementation(libs.junit)
            implementation(libs.room.testing)
        }
        androidInstrumentedTest.dependencies {
            implementation(libs.androidx.core)
            implementation(libs.androidx.runner)
            implementation(libs.androidx.rules)
            implementation(libs.androidx.junit)
            implementation(libs.androidx.truth)
            implementation(libs.androidx.espresso.core)
            implementation(libs.kotlinx.coroutines.test)
        }
    }
}

android {
    compileSdk = sdkVersion

    defaultConfig {
        minSdk = minSdkVersion
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.15"
    }
    namespace = "com.lambdadigamma.core"
}

dependencies {
    add("kspAndroid", libs.room.compiler)
    add("kspAndroid", libs.hilt.compiler)
}