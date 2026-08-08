package com.hashem.tilawa

class WindowsPlatform : Platform {
    override val name: String = "Windows"
}

actual fun getPlatform(): Platform = WindowsPlatform()
