// === TAMBAHAN PENTING DI BAGIAN ATAS ===
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Mendefinisikan versi plugin Google Services secara eksplisit.
        // Versi 4.4.1 adalah versi stabil yang umum dipakai.
        classpath("com.google.gms:google-services:4.4.1")
    }
}
// ========================================

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
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
