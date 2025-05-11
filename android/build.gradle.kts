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

// Add configuration to disable NDK download
gradle.startParameter.projectProperties["android.dir"] = "/nix/store/0w34z07sz8dn3bhdx01zq6qsk526zch4-androidsdk/libexec/android-sdk"
gradle.startParameter.projectProperties["android.sdk.dir"] = "/nix/store/0w34z07sz8dn3bhdx01zq6qsk526zch4-androidsdk/libexec/android-sdk"
gradle.startParameter.projectProperties["ndk.dir"] = "/nix/store/0w34z07sz8dn3bhdx01zq6qsk526zch4-androidsdk/libexec/android-sdk/ndk-bundle"

allprojects {
    repositories {
        google()
        mavenCentral()
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
