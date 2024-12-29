plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp")
}

val sdkVersion: Int by rootProject.extra
val minSdkVersion: Int by rootProject.extra
val targetSdkVersion: Int by rootProject.extra

val hiltVersion: String by rootProject.extra

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
    namespace = "com.lambdadigamma.fuel"

    defaultConfig {
        minSdk = minSdkVersion

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
}

dependencies {

    implementation(projects.modules.core)

    implementation(libs.kotlinx.coroutines.core)
    implementation(libs.kotlinx.coroutines.android)
    implementation(libs.androidx.lifecycle.livedata.ktx)

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)

    // Hilt
    implementation(libs.hilt.android)
    implementation(libs.androidx.hilt.navigation.compose)
    ksp(libs.hilt.compiler)

    // Compose
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.runtime.livedata)
    debugImplementation(libs.androidx.compose.ui.tooling)

    // Gson
    implementation(libs.gson)

    // Retrofit
    implementation(libs.retrofit)
    implementation(libs.converter.gson)
    implementation(libs.retrofit.mock)
    implementation(libs.retrofit.adapters.result)

    // Protobuf
    implementation(libs.protobuf.javalite)

    // Datastore
    implementation(libs.androidx.datastore)
    implementation(libs.androidx.datastore.preferences)

    // Room Database
    implementation(libs.room.runtime)
    implementation(libs.room.ktx)
    implementation(libs.androidx.room.paging)
    testImplementation(libs.room.testing)
    ksp(libs.room.compiler)

    implementation(libs.google.accompanist.placeholder.material)

}