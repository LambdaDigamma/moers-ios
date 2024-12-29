import com.android.build.gradle.internal.cxx.configure.gradleLocalProperties
import org.jetbrains.kotlin.util.capitalizeDecapitalize.toLowerCaseAsciiOnly

val tankerkoenigApiKey: String = gradleLocalProperties(rootDir).getProperty("TANKERKOENIG_API_KEY")

plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("kapt")
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
val espressoVersion: String by rootProject.extra

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
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
//        useIR = true
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.2.0"
    }
    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
    namespace = "com.lambdadigamma.moers"
}

dependencies {

    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.appcompat:appcompat:1.4.2")
    implementation("com.google.android.material:material:1.6.1")

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$coroutinesAndroidVersion")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:$coroutinesAndroidVersion")
    implementation("androidx.lifecycle:lifecycle-livedata-ktx:$lifecycleVersion")

    // Work
    implementation("androidx.work:work-runtime-ktx:2.7.1")

    // Compose
    implementation("androidx.compose.ui:ui:$composeVersion")
    implementation("androidx.compose.material:material:$composeVersion")
    implementation("androidx.compose.material3:material3:1.0.0-alpha14")
    implementation("androidx.compose.ui:ui-tooling-preview:$composeVersion")
    implementation("androidx.compose.runtime:runtime-livedata:1.3.0-alpha01")

    // Coil
    implementation("io.coil-kt:coil:$coilVersion")
    implementation("io.coil-kt:coil-compose:2.1.0")

    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.5.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.5.0")
    implementation("androidx.activity:activity-compose:1.5.0")
    implementation("androidx.navigation:navigation-compose:2.5.0")
    implementation("com.google.accompanist:accompanist-systemuicontroller:0.24.9-beta")
    implementation("com.google.accompanist:accompanist-webview:0.24.9-beta")

    testImplementation("junit:junit:$junitVersion")

    // Core library
    androidTestImplementation("androidx.test:core:$androidXTestVersion")

    // AndroidJUnitRunner and JUnit Rules
    androidTestImplementation("androidx.test:runner:$testRunnerVersion")
    androidTestImplementation("androidx.test:rules:$testRunnerVersion")

    // Assertions
    androidTestImplementation("androidx.test.ext:junit:$testJunitVersion")
    androidTestImplementation("androidx.test.ext:truth:$truthVersion")

    androidTestImplementation("androidx.test.espresso:espresso-core:$espressoVersion")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:$composeVersion")
    debugImplementation("androidx.compose.ui:ui-tooling:$composeVersion")

    implementation("com.google.dagger:hilt-android:$hiltVersion")
    implementation("androidx.hilt:hilt-navigation-compose:1.0.0")
    kapt("com.google.dagger:hilt-android-compiler:$hiltVersion")

    // Google Play Services
    implementation("com.google.android.gms:play-services-location:$gmsVersion")

    // Gson
    implementation("com.google.code.gson:gson:$gsonVersion")

    // Retrofit
    implementation("com.squareup.retrofit2:retrofit:$retrofitVersion")
    implementation("com.squareup.retrofit2:converter-gson:$retrofitVersion")
    implementation("com.squareup.retrofit2:retrofit-mock:$retrofitVersion")

    // Protobuf
    implementation("com.google.protobuf:protobuf-javalite:$protobufVersion")

    // Datastore
    implementation("androidx.datastore:datastore:$datastoreVersion")
    implementation("androidx.datastore:datastore-preferences:$datastoreVersion")

    // Room Database
    implementation("androidx.room:room-runtime:$roomVersion")
    implementation("androidx.room:room-ktx:$roomVersion")
    implementation("androidx.room:room-paging:$roomVersion")
    kapt("androidx.room:room-compiler:$roomVersion")
    testImplementation("androidx.room:room-testing:$roomVersion")

    // Autofill
    implementation("androidx.autofill:autofill:$autofillVersion")

    implementation("com.github.JamalMulla:ComposePrefs3:1.0.5")

    implementation(projects.modules.core)
    implementation(projects.modules.news)
    implementation(projects.modules.fuel)
    implementation(projects.modules.parking)
    implementation(projects.modules.rubbish)
    implementation(projects.modules.events)
    implementation(projects.modules.radio)

    implementation("com.google.accompanist:accompanist-permissions:0.24.9-beta")
    implementation("com.google.accompanist:accompanist-placeholder-material:0.24.13-rc")
    implementation("com.google.accompanist:accompanist-navigation-animation:0.26.0-alpha")

    // Review
    implementation("com.google.android.play:review:2.0.0")
    implementation("com.google.android.play:review-ktx:2.0.0")


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

kapt {
    correctErrorTypes = true
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
