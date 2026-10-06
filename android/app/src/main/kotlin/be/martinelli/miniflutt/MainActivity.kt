package be.martinelli.miniflutt

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// Exposes the local network permission (Android 17+, GrapheneOS) to Dart.
class MainActivity : FlutterActivity() {
    private val channelName = "miniflutt/local_network"
    private val permission = "android.permission.ACCESS_LOCAL_NETWORK"
    private val requestCode = 6400
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "status" -> result.success(status())
                    "request" -> request(result)
                    "openSettings" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                Uri.fromParts("package", packageName, null)
                            )
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // The permission only exists on Android versions that restrict local
    // network access. Elsewhere, access is always allowed.
    private fun isDefined(): Boolean {
        return try {
            packageManager.getPermissionInfo(permission, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun status(): String {
        if (!isDefined() ||
            checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
        ) {
            return "granted"
        }
        return "denied"
    }

    private fun request(result: MethodChannel.Result) {
        if (status() == "granted") {
            result.success("granted")
            return
        }
        if (pendingResult != null) {
            result.error("busy", "A permission request is already running", null)
            return
        }
        pendingResult = result
        requestPermissions(arrayOf(permission), requestCode)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != this.requestCode) return
        val result = pendingResult ?: return
        pendingResult = null
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        result.success(
            when {
                granted -> "granted"
                // Denied without the system asking: the user chose "Don't
                // allow" twice, so only the app settings can grant it now.
                !shouldShowRequestPermissionRationale(permission) ->
                    "permanentlyDenied"
                else -> "denied"
            }
        )
    }
}
