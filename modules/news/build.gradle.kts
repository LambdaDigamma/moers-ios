plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    kotlin("kapt")
}

/**
 * Accessing the defined global versions using a type safe delegate.
 */
val minSdkVersion: Int by rootProject.extra
val targetSdkVersion: Int by rootProject.extra
val sdkVersion: Int by rootProject.extra

val roomVersion: String by rootProject.extra
val retrofitVersion: String by rootProject.extra
val composeVersion: String by rootProject.extra

val hiltVersion: String by rootProject.extra
val coilVersion: String by rootProject.extra

val junitVersion: String by rootProject.extra
val androidXTestVersion: String by rootProject.extra
val testRunnerVersion: String by rootProject.extra
val testJunitVersion: String by rootProject.extra
val truthVersion: String by rootProject.extra
val espressoVersion: String by rootProject.extra

android {
    compileSdk = sdkVersion
    namespace = "com.lambdadigamma.news"

    defaultConfig {
        minSdk = minSdkVersion
        targetSdk = targetSdkVersion

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.2.0"
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation(projects.modules.core)
    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.appcompat:appcompat:1.4.2")
    implementation("com.google.android.material:material:1.6.1")

    // Compose
    implementation("androidx.compose.ui:ui:$composeVersion")
    implementation("androidx.compose.material3:material3:1.0.0-alpha14")
    implementation("androidx.compose.ui:ui-tooling-preview:1.1.1")
    implementation("androidx.compose.runtime:runtime-livedata:1.3.0-alpha01")
    debugImplementation("androidx.compose.ui:ui-tooling:1.1.1")

    // Coil
    implementation("io.coil-kt:coil:$coilVersion")
    implementation("io.coil-kt:coil-compose:2.1.0")

    // Hilt
    implementation("com.google.dagger:hilt-android:$hiltVersion")
    implementation("androidx.hilt:hilt-navigation-compose:1.0.0")
    kapt("com.google.dagger:hilt-android-compiler:$hiltVersion")

    // Room
    kapt("androidx.room:room-compiler:$roomVersion")
    kapt("androidx.room:room-compiler:$roomVersion")
    implementation("androidx.room:room-runtime:$roomVersion")
    implementation("androidx.room:room-ktx:$roomVersion")

    // Retrofit
    implementation("com.squareup.retrofit2:retrofit:$retrofitVersion")
    implementation("com.squareup.retrofit2:converter-simplexml:$retrofitVersion")
    implementation("com.squareup.retrofit2:converter-gson:$retrofitVersion")
    implementation("com.squareup.retrofit2:retrofit-mock:$retrofitVersion")

    testImplementation("junit:junit:$junitVersion")
    androidTestImplementation("androidx.test.ext:junit:$testJunitVersion")
    androidTestImplementation("androidx.test.espresso:espresso-core:$espressoVersion")

    // Accompanist
    implementation("com.google.accompanist:accompanist-webview:0.24.9-beta")
}