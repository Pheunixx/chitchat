plugins {
    id("com.google.gms.google-services") version "4.4.3" apply false
    id("com.android.application") version "8.7.3" apply false     // Android Application plugin
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false // Kotlin Android plugin (use 2.0.0 for latest compatibility)
    
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}