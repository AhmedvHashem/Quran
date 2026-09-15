import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    alias(libs.plugins.android.multiplatform.library)
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.skie)
    alias(libs.plugins.kotlin.native.nuget)
}

// ponytail: SQLDelight removed until a schema lands — its runtime drags
// co.touchlab:sqliter-driver (-lsqlite3) into every native link, and SQLiter
// has no linuxX64 variant (mingwX64 only links on a Windows host).
// Verified Aug 2026; re-add for android/apple with the first .sq file.
// Persistence gate for mingw/linux: .ai/arch/APP_STACKS_PLAN.md

kotlin {
    android {
        namespace = "com.hashem.tilawa.shared"
        compileSdk = libs.versions.android.compile.get().toInt()
        minSdk = libs.versions.android.min.get().toInt()

        compilerOptions {
            jvmTarget = JvmTarget.JVM_11
        }

        androidResources {
            enable = true
        }
    }

    val xcf = XCFramework("Shared")

    listOf(
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { appleTarget ->
        appleTarget.binaries.framework {
            baseName = "Shared"
            isStatic = true
            xcf.add(this)
        }
    }

    macosArm64().binaries.framework {
        baseName = "Shared"
        isStatic = true
        xcf.add(this)
    }

    linuxX64 {
        binaries.sharedLib {
            baseName = "Shared"
        }
    }

    mingwX64 {
        binaries.sharedLib {
            baseName = "Shared"
        }
    }

    applyDefaultHierarchyTemplate()

    sourceSets {
        commonMain.dependencies {
            implementation(libs.kotlin.coroutines.core)
            implementation(libs.kotlin.serialization)
            implementation(libs.kotlin.datetime)
            implementation(libs.ktor.client.core)
            implementation(libs.ktor.client.content.negotiation)
            implementation(libs.ktor.serialization.kotlinx.json)
            implementation(libs.multiplatform.settings)
            implementation(libs.kermit)
        }
        commonTest.dependencies {
            implementation(libs.testing.kotlin)
            implementation(libs.testing.kotlin.coroutines)
            implementation(libs.ktor.client.mock)
            implementation(libs.ktor.client.content.negotiation)
            implementation(libs.ktor.serialization.kotlinx.json)
            implementation(libs.multiplatform.settings.test)
        }
        androidMain.dependencies {
            implementation(libs.ktor.client.okhttp)
            implementation(libs.multiplatform.settings.no.arg)
        }
        appleMain.dependencies {
            implementation(libs.ktor.client.darwin)
            implementation(libs.multiplatform.settings.no.arg)
        }
        mingwX64Main.dependencies {
            implementation(libs.ktor.client.winhttp)
            implementation(libs.multiplatform.settings.no.arg)
        }
        linuxX64Main.dependencies {
            implementation(libs.ktor.client.curl)
        }
    }
}

nuget {
    publish {
        packageId = "Tilawa.Core"
        version = "0.1.0"
        authors = "Tilawa"
        description = "Tilawa shared Quran catalog and playback-domain core"
        rootPackage = "com.hashem.tilawa"
        include("com.hashem.tilawa.api")
        include("com.hashem.tilawa.domain.model")
    }
}
