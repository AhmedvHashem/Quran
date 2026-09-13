@file:OptIn(com.russhwolf.settings.ExperimentalSettingsImplementation::class)

package com.hashem.tilawa.data

import com.russhwolf.settings.Settings

internal actual fun defaultDownloadStore(): DownloadStore = SettingsDownloadStore(Settings())
