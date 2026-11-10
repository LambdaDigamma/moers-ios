plugins {
    id("com.android.library")
    alias(libs.plugins.detekt)
    alias(libs.plugins.junit)
    id("org.jetbrains.kotlin.plugin.parcelize")
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.composeCompiler)

}

android {
    compileSdk = 37
    namespace = "com.lambdadigamma.medialibrary"

    with (defaultConfig) {
        minSdk = 24
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

}

kotlin {
    compilerOptions {
        freeCompilerArgs.addAll(
            "-opt-in=kotlinx.coroutines.ExperimentalCoroutinesApi",
            "-opt-in=androidx.compose.material3.ExperimentalMaterial3Api"
        )
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
    testRuntimeOnly(libs.test.junit.platform.launcher)
    androidTestImplementation(libs.bundles.common.android.test)

}
