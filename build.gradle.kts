//plugins {
//    alias(libs.plugins.androidApplication) apply false
//    alias(libs.plugins.androidLibrary) apply false
//    alias(libs.plugins.composeCompiler) apply false
//    alias(libs.plugins.composeMultiplatform) apply false
//    alias(libs.plugins.kotlinMultiplatform) apply false
//    alias(libs.plugins.kotlinxSerialization) apply false
//    alias(libs.plugins.kmpNativeCoroutines) apply false
//    alias(libs.plugins.ksp) apply false
//    alias(libs.plugins.hilt) apply false
//}

/**
 * The extra object can be used for custom properties and makes them available to all
 * modules in the project.
 * The following are only a few examples of the types of properties you can define.
 */
extra["sdkVersion"] = 36
extra["minSdkVersion"] = 23
extra["targetSdkVersion"] = 36
extra["sourceCompatibility"] = JavaVersion.VERSION_17
extra["targetCompatibility"] = JavaVersion.VERSION_17

buildscript {

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    dependencies {
        classpath(libs.gradle)
        classpath(libs.kotlin.gradle.plugin)
        classpath(libs.hilt.android.gradle.plugin)
        classpath(libs.secrets.gradle.plugin)
    }
}

plugins {
    alias(libs.plugins.ksp) apply false
    alias(libs.plugins.kotlinMultiplatform) apply false
    alias(libs.plugins.androidLibrary) apply false
    id("com.google.protobuf") version "0.9.1" apply false
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}