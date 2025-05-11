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

// Set SDK locations using system properties instead
System.setProperty("android.dir", "/nix/store/0w34z07sz8dn3bhdx01zq6qsk526zch4-androidsdk/libexec/android-sdk")
System.setProperty("android.sdk.dir", "/nix/store/0w34z07sz8dn3bhdx01zq6qsk526zch4-androidsdk/libexec/android-sdk")
// Removed NDK references

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Disable NDK auto-download for all projects
    project.plugins.withId("com.android.application") {
        project.extensions.configure<com.android.build.gradle.AppExtension> {
            // Set SDK directory via system property instead of direct assignment
            // as sdkDirectory is likely a val that cannot be reassigned
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
