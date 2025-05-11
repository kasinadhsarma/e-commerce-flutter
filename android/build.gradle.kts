// Define Kotlin version as a project-level extra property
val kotlinVersion = "1.9.22"

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}

// Set SDK and NDK locations using system properties instead
System.setProperty("android.dir", "/nix/store/0w34z07sz8dn3bhdx01zq6qsk526zch4-androidsdk/libexec/android-sdk")
System.setProperty("android.sdk.dir", "/nix/store/0w34z07sz8dn3bhdx01zq6qsk526zch4-androidsdk/libexec/android-sdk")
System.setProperty("ndk.dir", "/nix/store/0w34z07sz8dn3bhdx01zq6qsk526zch4-androidsdk/libexec/android-sdk/ndk-bundle")

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Disable NDK auto-download for all projects
    project.plugins.withId("com.android.application") {
        project.extensions.configure<com.android.build.gradle.AppExtension> {
            sdkDirectory = file("/nix/store/0w34z07sz8dn3bhdx01zq6qsk526zch4-androidsdk/libexec/android-sdk")
        }
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
