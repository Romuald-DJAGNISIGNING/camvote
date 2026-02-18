import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Keep Gradle outputs outside OneDrive-synced project folders to avoid file locks
// during release merges/cleanup on Windows.
val localBuildRoot =
    File(
        System.getenv("LOCALAPPDATA") ?: System.getProperty("java.io.tmpdir"),
        "camvote-android-build",
    )
rootProject.layout.buildDirectory.value(rootProject.layout.dir(rootProject.provider { localBuildRoot }).get())

subprojects {
    val newSubprojectBuildDir: Directory = rootProject.layout.buildDirectory.dir(project.name).get()
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Ensure core library desugaring version satisfies plugins like flutter_local_notifications
subprojects {
    configurations.configureEach {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.android.tools" &&
                requested.name == "desugar_jdk_libs"
            ) {
                useVersion("2.1.4")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
