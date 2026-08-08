package com.hashem.tilawa

class LinuxPlatform : Platform {
    override val name: String = "Linux"
}

actual fun getPlatform(): Platform = LinuxPlatform()
