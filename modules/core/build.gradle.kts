plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp")
}

/**
 * Accessing the defined global versions using a type safe delegate.
 */
val sdkVersion: Int by rootProject.extra
val minSdkVersion: Int by rootProject.extra
val targetSdkVersion: Int by rootProject.extra

val gmsVersion: String by rootProject.extra
val roomVersion: String by rootProject.extra
val retrofitVersion: String by rootProject.extra

val junitVersion: String by rootProject.extra
val androidXTestVersion: String by rootProject.extra
val testRunnerVersion: String by rootProject.extra
val testJunitVersion: String by rootProject.extra
val truthVersion: String by rootProject.extra

val datastoreVersion: String by rootProject.extra

val composeVersion: String by rootProject.extra

val hiltVersion: String by rootProject.extra

android {
    compileSdk = sdkVersion

    defaultConfig {
        minSdk = minSdkVersion
        targetSdk = targetSdkVersion

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.15"
    }
    namespace = "com.lambdadigamma.core"
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)

    implementation(libs.kotlinx.coroutines.android)

    // Google Play Services
    implementation(libs.play.services.location)
    implementation(libs.androidx.work.runtime.ktx)

    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.core)
    androidTestImplementation(libs.androidx.runner)
    androidTestImplementation(libs.androidx.rules)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.truth)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(libs.kotlinx.coroutines.test)

    // Room Database
    implementation(libs.room.runtime)
    implementation(libs.room.ktx)
    implementation(libs.androidx.room.paging)
    ksp(libs.room.compiler)
    testImplementation(libs.room.testing)

    // Hilt
    implementation(libs.hilt.android)
    implementation(libs.androidx.hilt.navigation.compose)
    ksp(libs.hilt.compiler)

    // Retrofit
    implementation(libs.retrofit)
    implementation(libs.converter.simplexml)
    implementation(libs.converter.gson)
    implementation(libs.retrofit.mock)

    // Datastore
    implementation(libs.androidx.datastore)
    implementation(libs.androidx.datastore.preferences)

    // Compose
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.runtime.livedata)
    debugImplementation(libs.androidx.compose.ui.tooling)

    // Google Maps
    implementation(libs.maps.compose)
    implementation(libs.play.services.maps)

    implementation(libs.accompanist.swiperefresh)

}