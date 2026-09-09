import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    alias(libs.plugins.android.multiplatform.library)
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.kotlin.serialization)
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

    listOf(
        macosArm64(),
        macosX64()
    ).forEach { macTarget ->
        macTarget.binaries.framework {
            baseName = "Shared"
            isStatic = true
            xcf.add(this)
        }
        macTarget.binaries.sharedLib {
            baseName = "Shared"
        }
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
        // C-export façade shared by C-ABI targets (Windows, Linux, macOS GTK)
        val cApiMain by creating {
            dependsOn(commonMain.get())
        }
        mingwX64Main.get().dependsOn(cApiMain)
        linuxX64Main.get().dependsOn(cApiMain)
        macosMain.get().dependsOn(cApiMain)

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
        }
        androidMain.dependencies {
            implementation(libs.ktor.client.okhttp)
        }
        appleMain.dependencies {
            implementation(libs.ktor.client.darwin)
        }
        // ponytail: no SQLDelight driver on mingw/linux — SQLiter is Apple/Windows-only
        // and mingw cross-link from macOS lacks system sqlite3. Gate: .ai/arch/APP_STACKS_PLAN.md
        // (likely resolution: Room KMP with bundled sqlite). Ktor/settings/kermit work here.
        mingwX64Main.dependencies {
            implementation(libs.ktor.client.curl)
        }
        linuxX64Main.dependencies {
            implementation(libs.ktor.client.curl)
        }
    }
}
