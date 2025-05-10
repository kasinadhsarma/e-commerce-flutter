package com.example.eshop

import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDex
import android.content.Context

class EShopApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        // Initialize any native Android libraries or SDK configurations here
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        // Enable multidex support
        MultiDex.install(this)
    }
}