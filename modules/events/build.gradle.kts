plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    kotlin("kapt")
    id("com.google.protobuf") version "0.9.1"
}

val sdkVersion: Int by rootProject.extra
val minSdkVersion: Int by rootProject.extra
val targetSdkVersion: Int by rootProject.extra

val hiltVersion: String by rootProject.extra
val coilVersion: String by rootProject.extra

val composeVersion: String by rootProject.extra
val roomVersion: String by rootProject.extra
val retrofitVersion: String by rootProject.extra
val gsonVersion: String by rootProject.extra
val protobufVersion: String by rootProject.extra
val datastoreVersion: String by rootProject.extra
val coroutinesAndroidVersion: String by rootProject.extra
val lifecycleVersion: String by rootProject.extra

android {
    compileSdk = sdkVersion

    namespace = "com.lambdadigamma.events"

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
}

dependencies {

    implementation(projects.modules.core)

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$coroutinesAndroidVersion")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:$coroutinesAndroidVersion")
    implementation("androidx.lifecycle:lifecycle-livedata-ktx:$lifecycleVersion")

    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.appcompat:appcompat:1.4.2")
    implementation("com.google.android.material:material:1.6.1")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.3")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.4.0")

    // Hilt
    implementation("com.google.dagger:hilt-android:$hiltVersion")
    implementation("androidx.hilt:hilt-navigation-compose:1.0.0")
    kapt("com.google.dagger:hilt-android-compiler:$hiltVersion")

    // Coil
    implementation("io.coil-kt:coil:$coilVersion")
    implementation("io.coil-kt:coil-compose:2.1.0")

    // Compose
    implementation("androidx.compose.ui:ui:$composeVersion")
    implementation("androidx.compose.material3:material3:1.0.0-alpha14")
    implementation("androidx.compose.ui:ui-tooling-preview:1.1.1")
    implementation("androidx.compose.runtime:runtime-livedata:1.3.0-alpha01")
    debugImplementation("androidx.compose.ui:ui-tooling:1.1.1")

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

    implementation("com.google.accompanist:accompanist-placeholder-material:0.24.13-rc")

    // Work
    implementation("androidx.work:work-runtime-ktx:2.7.1")

}