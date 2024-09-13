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

            implementation("androidx.core:core-ktx:1.13.1")
            implementation("androidx.appcompat:appcompat:1.7.0")
            implementation("com.google.android.material:material:1.12.0")

            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

            // Google Play Services
            implementation("com.google.android.gms:play-services-location:21.3.0")
            implementation("androidx.work:work-runtime-ktx:2.9.1")

            // Room Database
            implementation("androidx.room:room-runtime:2.6.1")
            implementation("androidx.room:room-ktx:2.6.1")
            implementation("androidx.room:room-paging:2.6.1")

            // Hilt
            implementation("com.google.dagger:hilt-android:2.40")
            implementation("androidx.hilt:hilt-navigation-compose:1.0.0")

            // Retrofit
            implementation("com.squareup.retrofit2:retrofit:2.9.0")
            implementation("com.squareup.retrofit2:converter-simplexml:2.9.0")
            implementation("com.squareup.retrofit2:converter-gson:2.9.0")
            implementation("com.squareup.retrofit2:retrofit-mock:2.9.0")

            // Datastore
            implementation("androidx.datastore:datastore:1.0.0")
            implementation("androidx.datastore:datastore-preferences:1.0.0")

            // Compose
            implementation("androidx.compose.ui:ui:1.7.1")
            implementation("androidx.compose.material3:material3:1.3.0")
            implementation("androidx.compose.ui:ui-tooling-preview:1.7.1")
            implementation("androidx.compose.runtime:runtime-livedata:1.7.1")

            // Google Maps
            implementation("com.google.maps.android:maps-compose:6.1.2")
            implementation("com.google.android.gms:play-services-maps:19.0.0")

            implementation("com.google.accompanist:accompanist-swiperefresh:0.24.13-rc")

        }
        commonTest.dependencies {
//            implementation(libs.kotlin.test)
        }
    }
}

android {
    namespace = "com.lambdadigamma.core"
    compileSdk = 34
    defaultConfig {
        minSdk = 24
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    buildFeatures {
        compose = true
    }
}
