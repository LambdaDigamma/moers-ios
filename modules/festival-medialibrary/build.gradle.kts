import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.library")
    alias(libs.plugins.detekt)
    alias(libs.plugins.junit)
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.parcelize")
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.composeCompiler)

}

android {
    compileSdk = 36
    namespace = "com.lambdadigamma.medialibrary"

    with (defaultConfig) {
        minSdk = 24
        targetSdk = 35
    }

    defaultConfig {
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildFeatures {
        compose = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            consumerProguardFiles("proguard-rules.pro")
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

}

kotlin {
    compilerOptions {
        freeCompilerArgs.addAll(
            "-opt-in=kotlinx.coroutines.ExperimentalCoroutinesApi",
            "-opt-in=androidx.compose.material3.ExperimentalMaterial3Api"
        )
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {

    implementation(platform(libs.compose.bom))
    implementation(libs.compose.material3)
    implementation(libs.retrofit)
    implementation(libs.gson)
    implementation(libs.retrofit.gson)
    implementation(libs.room.ktx)
    implementation(libs.coil)
    implementation(libs.coil.network)
    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.android)

    testImplementation(libs.bundles.common.test)
    androidTestImplementation(libs.bundles.common.android.test)

}
