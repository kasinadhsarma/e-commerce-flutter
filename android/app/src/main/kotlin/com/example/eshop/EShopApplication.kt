package com.example.eshop

import io.flutter.app.FlutterApplication
import androidx.multidex.MultiDexApplication
import android.content.Context

class EShopApplication : MultiDexApplication() {
    override fun onCreate() {
        super.onCreate()
        // Initialize any native Android libraries or SDK configurations here
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        // MultiDex is automatically applied with MultiDexApplication
    }
}