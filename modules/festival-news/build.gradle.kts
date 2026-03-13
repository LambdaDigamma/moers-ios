import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.library")
    alias(libs.plugins.detekt)
    alias(libs.plugins.junit)
    id("org.jetbrains.kotlin.android")
    alias(libs.plugins.ksp)
    id("org.jetbrains.kotlin.plugin.parcelize")
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.composeCompiler)

}

android {
    namespace = "com.lambdadigamma.news"
    compileSdk = 36

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

    sourceSets {
        getByName("androidTest") {
            java.srcDir(project(":modules:core").file("src/androidTest/java"))
        }
        getByName("test") {
            java.srcDir(project(":modules:core").file("src/test/java"))
        }
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

    implementation(project(":modules:core"))
    implementation(project(":modules:festival-pages"))
    implementation(project(":modules:festival-medialibrary"))

    implementation(platform(libs.compose.bom))
    implementation(libs.accompanist.swipe.refresh)
    implementation(libs.coil)
    implementation(libs.coil.network)
    implementation(libs.compose.material3)
    implementation(libs.hilt)
    implementation(libs.kotlin.coroutines)
    implementation(libs.lifecycle.runtime.compose)
    implementation(libs.navigation)
    implementation(libs.navigation.hilt)
    implementation(libs.kotlin.serialization)
    implementation(libs.retrofit)
    implementation(libs.room)
    implementation(libs.timber)
    implementation(libs.gson)
    implementation(libs.retrofit.gson)
    implementation(libs.retrofit.mock)
    implementation(libs.gms.location)
    implementation(libs.gms.services)
    implementation(libs.maps.compose)
    implementation(libs.compose.ui.preview)
    implementation(libs.compose.runtime.livedata)
    implementation(libs.accompanist.swipe.refresh)
    implementation(libs.datastore)
    implementation(libs.datastore.preferences)
    implementation(libs.lifecycle.livedata.ktx)
    implementation(libs.lifecycle.livedata)
    implementation(libs.lifecycle.viewmodel.ktx)
    implementation(libs.core.ktx)
    implementation(libs.compose.webview)
    implementation(libs.compose.icons)
    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.android)
    implementation(project(":modules:festival-events"))
    testImplementation(libs.bundles.common.test)
    androidTestImplementation(libs.bundles.common.android.test)
    debugImplementation(libs.debug.compose.manifest)

    ksp(libs.hilt.compiler)
    add("kspAndroidTest", libs.test.android.hilt.compiler)

//    coreLibraryDesugaring(libs.desugar)

    detektPlugins(libs.detekt.compose.rules)

}
