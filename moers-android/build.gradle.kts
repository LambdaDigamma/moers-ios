import org.gradle.internal.extensions.stdlib.toDefaultLowerCase
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.Properties

val tankerkoenigApiKey: String = Properties().apply {
    rootProject.file("local.properties").takeIf { it.exists() }?.inputStream()?.use { load(it) }
}.getProperty("TANKERKOENIG_API_KEY", "\"\"")

object Keys {
    const val VERSION_NAME = "VERSION_NAME"
    const val VERSION_CODE = "VERSION_CODE"
}

fun getCurrentVersionProperties(): Properties {
    return Properties().apply {
        load(FileInputStream(versionPropertiesFile))
    }
}

plugins {
    alias(libs.plugins.androidApplication)
    alias(libs.plugins.ksp)
    alias(libs.plugins.hilt)
    alias(libs.plugins.secrets)
    alias(libs.plugins.composeCompiler)
}

/**
 * Accessing the defined global versions using a type safe delegate.
 */
val minSdkVersion = rootProject.extra["minSdkVersion"] as Int
val targetSdkVersion = rootProject.extra["targetSdkVersion"] as Int
val sdkVersion = rootProject.extra["sdkVersion"] as Int

val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties().apply {
    load(FileInputStream(keystorePropertiesFile))
}

val versionPropertiesFile = project.file("version.properties")
val versionProperties = Properties().apply {
    load(FileInputStream(versionPropertiesFile))
}

android {

    compileSdk = sdkVersion
    namespace = "com.lambdadigamma.moers"

    defaultConfig {
        applicationId = "com.lambdadigamma.moers"
        minSdk = minSdkVersion
        targetSdk = targetSdkVersion
        versionCode = versionProperties[Keys.VERSION_CODE].toString().toInt()
        versionName = versionProperties[Keys.VERSION_NAME].toString()

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }
    signingConfigs {
        create("release") {
            storeFile = rootProject.file("Keystore.jks")
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isDebuggable = false
            buildConfigField("String", "tankerkoenigApiKey", tankerkoenigApiKey)
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    buildFeatures {
        compose = true
        buildConfig = true
    }
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)

    implementation(libs.kotlinx.coroutines.core)
    implementation(libs.kotlinx.coroutines.android)
    implementation(libs.androidx.lifecycle.livedata.ktx)

    // Work
    implementation(libs.androidx.work.runtime.ktx)

    // Compose
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.runtime.livedata)
    implementation(libs.androidx.material)
    implementation(libs.androidx.material.icons.core)
    implementation(libs.androidx.material.icons.extended)
    implementation(libs.androidx.material3)

    // Coil
    implementation(libs.coil)
    implementation(libs.coil.network.okhttp)

    implementation(libs.lifecycle.runtime.ktx)
    implementation(libs.lifecycle.viewmodel.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.accompanist.systemuicontroller)
    implementation(libs.accompanist.webview)

    testImplementation(libs.junit)

    // Core library
    androidTestImplementation(libs.androidx.core)

    // AndroidJUnitRunner and JUnit Rules
    androidTestImplementation(libs.androidx.runner)
    androidTestImplementation(libs.androidx.rules)

    // Assertions
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.truth)

    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.ui.test.junit4)
    debugImplementation(libs.androidx.compose.ui.tooling)

    implementation(libs.hilt.android)
    implementation(libs.androidx.hilt.lifecycle.viewmodel.compose)
    ksp(libs.hilt.compiler)

    // Google Play Services
    implementation(libs.play.services.location)

    // Gson
    implementation(libs.gson)

    // Retrofit
    implementation(libs.retrofit)
    implementation(libs.converter.gson)
    implementation(libs.retrofit.mock)

    // Protobuf
    implementation(libs.protobuf.javalite)

    // Datastore
    implementation(libs.androidx.datastore)
    implementation(libs.androidx.datastore.preferences)

    // Room Database
    implementation(libs.room.runtime)
    implementation(libs.room.ktx)
    implementation(libs.androidx.room.paging)
    ksp(libs.room.compiler)
    testImplementation(libs.room.testing)

    // Autofill
    implementation(libs.androidx.autofill)

    implementation(libs.composeprefs3)

    implementation(projects.modules.core)
    implementation(projects.modules.news)
    implementation(projects.modules.fuel)
    implementation(projects.modules.parking)
    implementation(projects.modules.rubbish)
    implementation(projects.modules.events)
    implementation(projects.modules.radio)

    implementation(libs.google.accompanist.permissions)
    implementation(libs.google.accompanist.placeholder.material)

    // Review
    implementation(libs.review)
    implementation(libs.review.ktx)

}

tasks.register("incrementVersion") {
    group = "versioning"
    description = "Increments the version to make the app ready for next release."
    doLast {

        val versionProperties = getCurrentVersionProperties()
        val versionName = versionProperties.getProperty(Keys.VERSION_NAME)
        val mode = project.properties["mode"]?.toString()?.toDefaultLowerCase()

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
            project.properties["overrideVersion"]?.toString()?.toDefaultLowerCase()
        overrideVersion?.let { newVersion = it }

        versionProperties.setProperty(Keys.VERSION_NAME, newVersion)
        versionProperties.store(versionPropertiesFile.writer(), null)

    }
}

tasks.register("incrementVersionCode") {
    group = "versioning"
    description = "Increments the version code."
    doLast {

        val versionProperties = getCurrentVersionProperties()
        val currentVersionCode = versionProperties[Keys.VERSION_CODE].toString().toInt()
        versionProperties.setProperty(Keys.VERSION_CODE, (currentVersionCode + 1).toString())
        versionProperties.store(versionPropertiesFile.writer(), null)

    }
}

secrets {
    // To add your Maps API key to this project:
    // 1. Add this line to your local.properties file, where YOUR_API_KEY is your API key:
    //        MOERS_MAPS_API_KEY=YOUR_API_KEY
    defaultPropertiesFileName = "local.defaults.properties"
}
