package uz.freyzan.mdocumentsmanager

import android.app.ActivityManager
import android.content.Context
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_PROFILE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "read" -> result.success(readDeviceProfile())
                    else -> result.notImplemented()
                }
            }
    }

    private fun readDeviceProfile(): Map<String, Any> {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memory = ActivityManager.MemoryInfo().also(activityManager::getMemoryInfo)
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        return mapOf(
            "totalMemoryBytes" to memory.totalMem,
            "lowRamDevice" to activityManager.isLowRamDevice,
            "powerSaveMode" to power.isPowerSaveMode,
        )
    }

    private companion object {
        const val DEVICE_PROFILE_CHANNEL = "uz.freyzan.mdocumentsmanager/device_profile"
    }
}
