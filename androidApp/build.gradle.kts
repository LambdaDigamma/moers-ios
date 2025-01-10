import org.jetbrains.kotlin.konan.properties.loadProperties
import org.jetbrains.kotlin.util.capitalizeDecapitalize.toLowerCaseAsciiOnly
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.Properties

val tankerkoenigApiKey: String = loadProperties(project.rootProject.file("local.properties").path).getProperty("TANKERKOENIG_API_KEY")

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
    id("com.android.application")
    kotlin("android")
    alias(libs.plugins.ksp)
    id("com.google.protobuf")
    id("dagger.hilt.android.plugin")
    id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin")
    alias(libs.plugins.composeCompiler)
}

/**
 * Accessing the defined global versions using a type safe delegate.
 */
val minSdkVersion: Int by rootProject.extra
val targetSdkVersion: Int by rootProject.extra
val sdkVersion: Int by rootProject.extra

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

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isDebuggable = false
            buildConfigField("String", "tankerkoenigApiKey", tankerkoenigApiKey)
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
//        useIR = true
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.15"
    }
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
    namespace = "com.lambdadigamma.moers"

    signingConfigs {
        create("release") {
            storeFile = file("$rootDir/keystore.jks")
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
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
    implementation(libs.androidx.material3)

    // Coil
    implementation(libs.coil.core)
    implementation(libs.coil.compose)

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
    androidTestImplementation(libs.androidx.ui.test.junit4)
    debugImplementation(libs.androidx.compose.ui.tooling)

    implementation(libs.hilt.android)
    implementation(libs.androidx.hilt.navigation.compose)
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
    implementation(libs.androidx.navigation.compose)

    // Review
    implementation(libs.review)
    implementation(libs.review.ktx)

}

protobuf {
    protoc {
        artifact = "com.google.protobuf:protoc:${libs.versions.protobufVersion.get()}"
    }
    generateProtoTasks {
        all().forEach { task ->
            task.builtins {
                create("java") {
                    option("lite")
                }
            }
        }
    }
}


tasks.create("incrementVersion") {
    group = "versioning"
    description = "Increments the version to make the app ready for next release."
    doLast {

        val versionProperties = getCurrentVersionProperties()
        val versionName = versionProperties.getProperty(Keys.VERSION_NAME)
        val mode = project.properties["mode"]?.toString()?.toLowerCaseAsciiOnly()

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
            project.properties["overrideVersion"]?.toString()?.toLowerCaseAsciiOnly()
        overrideVersion?.let { newVersion = it }

        versionProperties.setProperty(Keys.VERSION_NAME, newVersion)
        versionProperties.store(versionPropertiesFile.writer(), null)

    }
}

tasks.create("incrementVersionCode") {
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
    //        MAPS_API_KEY=YOUR_API_KEY
    defaultPropertiesFileName = "local.defaults.properties"
}
