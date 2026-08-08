package com.hashem.tilawa

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform