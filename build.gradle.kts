plugins {
    kotlin("jvm") version "1.9.24"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
}

application {
    mainClass.set("chapter2.MainKt")
}

tasks.test {
    useJUnitPlatform()
}

tasks.register<JavaExec>("runFunctionsExercises") {
    group = "application"
    description = "Run Chapter 2 functions/collections exercises"
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("chapter2.functions.FunctionExercisesKt")
}

tasks.register<JavaExec>("runClassesExercises") {
    group = "application"
    description = "Run Chapter 2 classes/OOP exercises"
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("chapter2.classes.ClassExercisesKt")
}

tasks.register<JavaExec>("runMilestone2") {
    group = "application"
    description = "Run Milestone 2 demo"
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("chapter2.milestones.Milestone2_RomualdSIGNINGKt")
}

tasks.register<JavaExec>("runMilestone3") {
    group = "application"
    description = "Run Milestone 3 demo"
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("chapter2.milestones.Milestone3_RomualdSIGNINGKt")
}

