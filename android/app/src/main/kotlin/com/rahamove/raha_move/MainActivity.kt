package com.rahamove.raha_move

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "raha/reminders/system")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "permissionStatus" -> {
            val notificationsEnabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
            val status = when {
              !notificationsEnabled -> "denied"
              Build.VERSION.SDK_INT < 33 -> "granted"
              checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED -> "granted"
              ActivityCompat.shouldShowRequestPermissionRationale(this, android.Manifest.permission.POST_NOTIFICATIONS) -> "denied"
              else -> "notDetermined"
            }
            result.success(status)
          }
          "openNotificationSettings" -> {
            startActivity(Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
              putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
              data = Uri.parse("package:$packageName")
            })
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }
}
