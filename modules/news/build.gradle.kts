import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.room)
    alias(libs.plugins.ksp)
    alias(libs.plugins.hilt)
}

kotlin {
    androidTarget {
        @OptIn(ExperimentalKotlinGradlePluginApi::class)
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }
    
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach {
        it.binaries.framework {
            baseName = "news"
            isStatic = true
        }
    }

    sourceSets.commonMain {
        kotlin.srcDir("build/generated/ksp/metadata")
    }

    sourceSets {
        androidMain.dependencies {
            implementation(libs.androidx.core.ktx)
            implementation(libs.androidx.appcompat)
            implementation(libs.material)

            // Compose
            implementation(libs.androidx.compose.ui)
            implementation(libs.androidx.material3)
            implementation(libs.androidx.compose.ui.tooling.preview)
            implementation(libs.androidx.compose.runtime.livedata)

            // Coil
            implementation(libs.coil.core)
            implementation(libs.coil.compose)

            // Hilt
            implementation(libs.hilt.android)
            implementation(libs.androidx.hilt.navigation.compose)
//            ksp(libs.hilt.compiler)

            // Room
            implementation(libs.room.runtime.android)

        }
        commonMain.dependencies {
            implementation(projects.modules.core)


            implementation(libs.room.runtime)
            implementation(libs.sqlite.bundled)
            implementation(libs.xmlutil.core)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }
}

dependencies {
//    add("kspAndroid", libs.room.compiler)
//    add("kspIosSimulatorArm64", libs.room.compiler)
//    add("kspIosX64", libs.room.compiler)
//    add("kspIosArm64", libs.room.compiler)
}

android {
    namespace = "app.moers.news"
    compileSdk = 34
    defaultConfig {
        minSdk = 24
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

room {
    schemaDirectory("$projectDir/schemas")
}