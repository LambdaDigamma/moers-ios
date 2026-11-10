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
    namespace = "com.lambdadigamma.pages"

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

    sourceSets {
        getByName("androidTest") {
            kotlin.directories += project(":modules:core").file("src/androidTest/java").path
        }
        getByName("test") {
            kotlin.directories += project(":modules:core").file("src/test/java").path
        }
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

    implementation(project(":modules:core"))
    implementation(project(":modules:medialibrary"))
    implementation(project(":modules:prosemirror"))

    implementation(platform(libs.compose.bom))
    implementation(libs.compose.material3)
    implementation(libs.hilt)
//    implementation(libs.kotlin.coroutines)
    implementation(libs.lifecycle.runtime.compose)
    implementation(libs.navigation)
    implementation(libs.navigation.hilt)
//    implementation(libs.kotlin.serialization)
    implementation(libs.compose.icons)
    implementation(libs.gson)
    implementation(libs.retrofit)
    implementation(libs.retrofit.gson)
    implementation(libs.retrofit.mock)
    implementation(libs.room)
    implementation(libs.room.ktx)
    implementation(libs.timber)
    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.android)
//    implementation(libs.lifecycle.runtime.compose.android)
//    implementation(libs.compose.ui.preview)
//    implementation(libs.compose.runtime.livedata)
//    implementation(libs.accompanist.swipe.refresh)
    implementation(libs.lifecycle.viewmodel.ktx)
//    implementation("androidx.core:core-ktx:1.10.1")

    testImplementation(libs.bundles.common.test)
    testRuntimeOnly(libs.test.junit.platform.launcher)
    androidTestImplementation(libs.bundles.common.android.test)
    debugImplementation(libs.debug.compose.manifest)

//    coreLibraryDesugaring(libs.desugar)
//    detektPlugins(libs.detekt.compose.rules)

}
