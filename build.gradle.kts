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
extra["sdkVersion"] = 35
extra["minSdkVersion"] = 21
extra["targetSdkVersion"] = 35

var kotlinVersion = "1.9.25"

extra["kotlinVersion"] = kotlinVersion
extra["coroutinesAndroidVersion"] = "1.6.4"
extra["lifecycleVersion"] = "2.5.0"
extra["hiltVersion"] = "2.42"
extra["composeVersion"] = "1.1.1"
extra["coilVersion"] = "1.2.1"
extra["datastoreVersion"] = "1.0.0"
extra["protobufVersion"] = "3.19.0"
extra["retrofitVersion"] = "2.9.0"
extra["autofillVersion"] = "1.1.0"
extra["gmsVersion"] = "19.0.1"

extra["roomVersion"] = "2.4.2"
extra["gsonVersion"] = "2.9.0"

extra["junitVersion"] = "4.13.2"
extra["androidXTestVersion"] = "1.4.0"
extra["testRunnerVersion"] = "1.4.0"
extra["testJunitVersion"] = "1.1.3"
extra["truthVersion"] = "1.4.0"

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
    id("com.google.devtools.ksp") version "1.9.25-1.0.20" apply false
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}