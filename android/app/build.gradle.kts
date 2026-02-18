import java.io.FileInputStream
import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasKeystore = keystorePropertiesFile.exists()
if (hasKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.camvote.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    val buildingBundle = gradle.startParameter.taskNames.any {
        it.contains("bundle", ignoreCase = true)
    }
    val enableReleaseMinify =
        (findProperty("camvote.minifyRelease") as String?)?.toBooleanStrictOrNull() ?: false

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

// UPDATED: Modern way to set jvmTarget
    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    //kotlinOptions {
     //   jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.camvote.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
	    // minSdk = flutter.minSdkVersion         // Putting a more suitable minSDK for my computer and phone
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Generate lean APKs per ABI plus a universal fallback APK.
    splits {
        abi {
            isEnable = !buildingBundle
            if (!buildingBundle) {
                reset()
                include("armeabi-v7a", "arm64-v8a", "x86_64")
                isUniversalApk = true
            }
        }
    }

    signingConfigs {
        create("release") {
            if (hasKeystore) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = enableReleaseMinify
            isShrinkResources = enableReleaseMinify
            if (enableReleaseMinify) {
                proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro",
                )
            }
            signingConfig = if (hasKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Fix missing ML Kit language-specific classes in release builds
    implementation("com.google.mlkit:text-recognition-chinese:16.0.0")
    implementation("com.google.mlkit:text-recognition-devanagari:16.0.0")
    implementation("com.google.mlkit:text-recognition-japanese:16.0.0")
    implementation("com.google.mlkit:text-recognition-korean:16.0.0")
}

flutter {
    source = "../.."
}

// Flutter tooling expects Android artifacts under <flutter_root>/build/app/outputs/*.
//
// This repo optionally relocates Gradle build directories to avoid Windows/OneDrive file locks.
// When that happens, Flutter may fail to locate the produced .aab/.apk files even though Gradle
// built them successfully. These sync tasks copy the final artifacts back into the conventional
// Flutter output folders so `flutter build ...` and CI workflows can pick them up reliably.
afterEvaluate {
    val flutterRootDir = rootProject.projectDir.parentFile
    val flutterBuildAppDir = File(flutterRootDir, "build/app")
    val flutterOutputsDir = File(flutterRootDir, "build/app/outputs")
    val appBuildDir = layout.buildDirectory.get().asFile
    val syncNeeded = try {
        appBuildDir.canonicalFile != flutterBuildAppDir.canonicalFile
    } catch (_: Exception) {
        appBuildDir.absolutePath != flutterBuildAppDir.absolutePath
    }

    if (!syncNeeded) {
        return@afterEvaluate
    }

    val syncBundleRelease = tasks.register("syncFlutterBundleRelease") {
        // Force execution when destination is missing even if bundleRelease is UP-TO-DATE.
        outputs.file(File(flutterOutputsDir, "bundle/release/app-release.aab"))
        doLast {
            val src = layout.buildDirectory.file("outputs/bundle/release/app-release.aab").get().asFile
            if (!src.exists()) return@doLast
            val dst = File(flutterOutputsDir, "bundle/release/app-release.aab")
            dst.parentFile.mkdirs()
            if (src.absolutePath != dst.absolutePath) {
                src.copyTo(dst, overwrite = true)
            }
        }
    }

    val syncApkRelease = tasks.register("syncFlutterApkRelease") {
        outputs.dir(File(flutterOutputsDir, "flutter-apk"))
        doLast {
            val dstDir = File(flutterOutputsDir, "flutter-apk")
            dstDir.mkdirs()

            val sources = listOf(
                layout.buildDirectory.dir("outputs/flutter-apk").get().asFile,
                layout.buildDirectory.dir("outputs/apk/release").get().asFile,
            )
            for (srcDir in sources) {
                if (!srcDir.exists() || srcDir.absolutePath == dstDir.absolutePath) continue
                srcDir.listFiles()?.forEach { file ->
                    if (!file.isFile || !file.name.endsWith(".apk", ignoreCase = true)) return@forEach
                    file.copyTo(File(dstDir, file.name), overwrite = true)
                }
            }
        }
    }

    // Finalize common Flutter-invoked tasks.
    tasks.matching { it.name == "bundleRelease" }.configureEach {
        finalizedBy(syncBundleRelease)
    }
    tasks.matching { it.name == "assembleRelease" }.configureEach {
        finalizedBy(syncApkRelease)
    }
}
