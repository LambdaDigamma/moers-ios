import com.android.build.gradle.internal.cxx.configure.gradleLocalProperties
import org.jetbrains.kotlin.gradle.utils.loadPropertyFromResources
import org.jetbrains.kotlin.konan.properties.loadProperties
import org.jetbrains.kotlin.util.capitalizeDecapitalize.toLowerCaseAsciiOnly



val tankerkoenigApiKey: String = loadProperties(project.rootProject.file("local.properties").path).getProperty("TANKERKOENIG_API_KEY")
//val tankerkoenigApiKey: String = project.rootProject.file("local.properties").getProperty("TANKERKOENIG_API_KEY")

plugins {
    id("com.android.application")
    kotlin("android")
    id("com.google.devtools.ksp")
    id("com.google.protobuf") version "0.9.1"
    id("dagger.hilt.android.plugin")
    id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin")
}

project.version = "1.0.2"

/**
 * Accessing the defined global versions using a type safe delegate.
 */
val minSdkVersion: Int by rootProject.extra
val targetSdkVersion: Int by rootProject.extra
val sdkVersion: Int by rootProject.extra

val hiltVersion: String by rootProject.extra
val composeVersion: String by rootProject.extra
val roomVersion: String by rootProject.extra
val datastoreVersion: String by rootProject.extra
val protobufVersion: String by rootProject.extra
val gsonVersion: String by rootProject.extra
val retrofitVersion: String by rootProject.extra
val autofillVersion: String by rootProject.extra
val gmsVersion: String by rootProject.extra
val coilVersion: String by rootProject.extra

val junitVersion: String by rootProject.extra
val androidXTestVersion: String by rootProject.extra
val testRunnerVersion: String by rootProject.extra
val testJunitVersion: String by rootProject.extra
val truthVersion: String by rootProject.extra

val coroutinesAndroidVersion: String by rootProject.extra
val lifecycleVersion: String by rootProject.extra

android {
    compileSdk = sdkVersion

    defaultConfig {
        applicationId = "com.lambdadigamma.moers"
        minSdk = minSdkVersion
        targetSdk = targetSdkVersion
        versionCode = 18
        versionName = "1.0.2"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
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
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.material)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.runtime.livedata)

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
        artifact = "com.google.protobuf:protoc:${protobufVersion}"
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
        var (major, minor, patch) = project.version.toString().split(".")
        val mode = project.properties["mode"]?.toString()?.toLowerCaseAsciiOnly()
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

        val newBuild = buildFile
            .readText()
            .replaceFirst(Regex("version = .+"), "version = \"$newVersion\"")
            .replaceFirst(Regex("versionName = .+\""), "versionName = \"$newVersion\"")
        buildFile.writeText(newBuild)
    }
}

tasks.create("incrementVersionCode") {
    group = "versioning"
    description = "Increments the version code."
    doLast {
        val newBuild = buildFile
            .readText()
            .replaceFirst(
                Regex("versionCode = \\d+"),
                "versionCode = ${(android.defaultConfig.versionCode ?: 0) + 1}"
            )
        buildFile.writeText(newBuild)
    }
}

secrets {
    // To add your Maps API key to this project:
    // 1. Add this line to your local.properties file, where YOUR_API_KEY is your API key:
    //        MAPS_API_KEY=YOUR_API_KEY
    defaultPropertiesFileName = "local.defaults.properties"
}
