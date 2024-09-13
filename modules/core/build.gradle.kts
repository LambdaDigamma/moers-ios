import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
}

kotlin {
    jvm()
    androidTarget {
        publishLibraryVariants("release")
        @OptIn(ExperimentalKotlinGradlePluginApi::class)
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_1_8)
        }
    }
    iosX64()
    iosArm64()
    iosSimulatorArm64()
    linuxX64()

    sourceSets {
        val commonMain by getting {
            dependencies {
                //put your multiplatform dependencies here
            }
        }
        val androidMain by getting {
            dependencies {
                implementation(libs.retrofit)
                implementation(libs.ktor.client.okhttp)
                implementation(libs.androidx.core.ktx)
                implementation(libs.androidx.appcompat)
                implementation(libs.material)
                implementation(libs.kotlinx.coroutines.android)
                implementation(libs.play.services.location)
                implementation(libs.androidx.work.runtime.ktx)
                implementation(libs.room.runtime)
                implementation(libs.room.ktx)
                implementation(libs.room.paging)
                implementation(libs.hilt)
                implementation(libs.retrofit.simplexml)
                implementation(libs.retrofit.gson)
                implementation(libs.retrofit.mock)
                implementation(libs.datastore)
                implementation(libs.datastore.preferences)
                implementation(libs.compose.material3)
                implementation(libs.compose.runtime.livedata)
                implementation(libs.androidx.compose.ui.tooling)
                implementation(libs.google.maps.compose)
                implementation(libs.google.play.services.maps)
                implementation(libs.accompanist.swiperefresh)
            }
        }
        val commonTest by getting {
            dependencies {
                implementation(libs.kotlin.test)
            }
        }
    }
}

android {
    namespace = "com.lambdadigamma.core"
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    defaultConfig {
        minSdk = libs.versions.android.minSdk.get().toInt()
    }
}
