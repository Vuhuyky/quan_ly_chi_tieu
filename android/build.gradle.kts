// File: android/build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 🔹 Plugin Google Services (Firebase)
        classpath("com.google.gms:google-services:4.4.2")
        // 🔹 Plugin Kotlin Gradle
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.23")
    }
}

plugins {
    id("org.jetbrains.kotlin.android") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// (Phần này của bạn ok, giữ nguyên)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
