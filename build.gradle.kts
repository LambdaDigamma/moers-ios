/**
 * The extra object can be used for custom properties and makes them available to all
 * modules in the project.
 */
extra["sdkVersion"] = 37
extra["minSdkVersion"] = 24
extra["targetSdkVersion"] = 36

buildscript {
    dependencies {
        // AGP 9 provides built-in Kotlin. Pin KGP so it matches the Compose compiler plugin.
        classpath(libs.kotlin.gradle.plugin)
    }
}

plugins {
    alias(libs.plugins.androidApplication) apply false
    alias(libs.plugins.androidLibrary) apply false
    alias(libs.plugins.composeCompiler) apply false
    alias(libs.plugins.kotlin.parcelize) apply false
    alias(libs.plugins.kotlin.serialization) apply false
    alias(libs.plugins.ksp) apply false
    alias(libs.plugins.hilt) apply false
    alias(libs.plugins.protobuf) apply false
    alias(libs.plugins.secrets) apply false
    alias(libs.plugins.google.services) apply false
    alias(libs.plugins.firebase.crashlytics) apply false
    alias(libs.plugins.aboutLibraries) apply false
    alias(libs.plugins.detekt) apply false
    alias(libs.plugins.junit) apply false
}
