plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    kotlin("kapt")
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

val espressoVersion: String by rootProject.extra

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
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.2.0"
    }
    testNamespace = "com.lambdadigamma.core"
    namespace = "com.lambdadigamma.core"
}

dependencies {

    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.appcompat:appcompat:1.4.2")
    implementation("com.google.android.material:material:1.6.1")

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4")

    // Google Play Services
    implementation("com.google.android.gms:play-services-location:$gmsVersion")
    implementation("androidx.work:work-runtime-ktx:2.7.1")

    testImplementation("junit:junit:$junitVersion")
    androidTestImplementation("androidx.test:core:$androidXTestVersion")
    androidTestImplementation("androidx.test:runner:$testRunnerVersion")
    androidTestImplementation("androidx.test:rules:$testRunnerVersion")
    androidTestImplementation("androidx.test.ext:junit:$testJunitVersion")
    androidTestImplementation("androidx.test.ext:truth:$truthVersion")
    androidTestImplementation("androidx.test.espresso:espresso-core:$espressoVersion")
    androidTestImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.6.4")

    // Room Database
    implementation("androidx.room:room-runtime:$roomVersion")
    implementation("androidx.room:room-ktx:$roomVersion")
    implementation("androidx.room:room-paging:$roomVersion")
    kapt("androidx.room:room-compiler:$roomVersion")
    testImplementation("androidx.room:room-testing:$roomVersion")

    // Hilt
    implementation("com.google.dagger:hilt-android:$hiltVersion")
    implementation("androidx.hilt:hilt-navigation-compose:1.0.0")
    kapt("com.google.dagger:hilt-android-compiler:$hiltVersion")

    // Retrofit
    implementation("com.squareup.retrofit2:retrofit:$retrofitVersion")
    implementation("com.squareup.retrofit2:converter-simplexml:$retrofitVersion")
    implementation("com.squareup.retrofit2:converter-gson:$retrofitVersion")
    implementation("com.squareup.retrofit2:retrofit-mock:$retrofitVersion")

    // Datastore
    implementation("androidx.datastore:datastore:$datastoreVersion")
    implementation("androidx.datastore:datastore-preferences:$datastoreVersion")

    // Compose
    implementation("androidx.compose.ui:ui:$composeVersion")
    implementation("androidx.compose.material3:material3:1.0.0-alpha14")
    implementation("androidx.compose.ui:ui-tooling-preview:1.1.1")
    implementation("androidx.compose.runtime:runtime-livedata:1.3.0-alpha01")
    debugImplementation("androidx.compose.ui:ui-tooling:1.1.1")

    // Google Maps
    implementation("com.google.maps.android:maps-compose:2.5.3")
    implementation("com.google.android.gms:play-services-maps:18.0.2")

    implementation("com.google.accompanist:accompanist-swiperefresh:0.24.13-rc")

}