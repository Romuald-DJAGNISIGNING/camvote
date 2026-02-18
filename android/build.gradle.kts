import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use the project-root build directory by default so Flutter tooling can find
// APK/AAB artifacts. Optionally override with CAMVOTE_ANDROID_BUILD_ROOT for
// Windows hosts that need a non-OneDrive location.
val buildRootDir =
    System.getenv("CAMVOTE_ANDROID_BUILD_ROOT")
        ?.trim()
        ?.takeIf { it.isNotEmpty() }
        ?.let(::File)
        ?: rootProject.projectDir.resolve("../build")

rootProject.layout.buildDirectory.value(rootProject.layout.dir(rootProject.provider { buildRootDir }).get())

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

// Some transitive Android library plugins can fail lintVital on CI/Windows with
// missing generated lint-resources artifacts. Keep release builds deterministic
// by disabling only the lintVital analyze task on subprojects.
subprojects {
    tasks.configureEach {
        if (name == "lintVitalAnalyzeRelease") {
            enabled = false
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
