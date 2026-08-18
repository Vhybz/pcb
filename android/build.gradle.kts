/**
 * NOTE: If you encounter "Incompatible Gradle JVM version" errors, please ensure you are using
 * the Embedded JDK (17 or 21) in Android Studio settings (Settings > Build, Execution, Deployment > Build Tools > Gradle).
 * Java 25 is currently in use, which may be too new for some Gradle/AGP versions.
 */
import com.android.build.gradle.BaseExtension

// plugins block moved to settings.gradle.kts or used with 'apply false'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid: (Project) -> Unit = { p ->
        val android = p.extensions.findByName("android") as? BaseExtension
        android?.apply {
            buildToolsVersion("34.0.0")
        }
    }
    if (project.state.executed) {
        configureAndroid(project)
    } else {
        project.afterEvaluate {
            configureAndroid(project)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}