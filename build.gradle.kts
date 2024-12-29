////project.ext.set("sourceCompatibility", JavaVersion.VERSION_11)
////project.ext.set("targetCompatibility", JavaVersion.VERSION_11)
//
//
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
extra["sdkVersion"] = 34
extra["minSdkVersion"] = 21
extra["targetSdkVersion"] = 34

var kotlinVersion = "1.7.0"
var gradleVersion = "7.3.0"

extra["kotlinVersion"] = kotlinVersion
extra["gradleVersion"] = gradleVersion
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
extra["espressoVersion"] = "3.4.0"

/**
 * The buildscript block is where you configure the repositories and
 * dependencies for Gradle itself — meaning, you should not include dependencies
 * for your modules here. For example, this block includes the Android plugin for
 * Gradle as a dependency because it provides the additional instructions Gradle
 * needs to build Android app modules.
 */
buildscript {

    val kotlinVersion = "1.7.0" //: String by rootProject.extra
    val hiltAndroid = "2.42"
    val gradleVersion: String by rootProject.extra


    /**
     * The repositories block configures the repositories Gradle uses to
     * search or download the dependencies. Gradle pre-configures support for remote
     * repositories such as JCenter, Maven Central, and Ivy. You can also use local
     * repositories or define your own remote repositories. The code below defines
     * JCenter as the repository Gradle should use to look for its dependencies.
     */
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
//        maven("https://oss.sonatype.org/content/repositories/snapshots")
    }

    /**
     * The dependencies block configures the dependencies Gradle needs to use
     * to build your project. The following line adds Android plugin for Gradle
     * version 7.0.4 as a classpath dependency.
     */
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.0")
        classpath("com.google.dagger:hilt-android-gradle-plugin:${hiltAndroid}")
        classpath("com.google.android.libraries.mapsplatform.secrets-gradle-plugin:secrets-gradle-plugin:2.0.1")
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}