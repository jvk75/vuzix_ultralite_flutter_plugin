package com.loitsut.vuzix_ultralite_flutter_plugin

import android.content.Context
import androidx.lifecycle.Observer
import com.vuzix.ultralite.UltraliteSDK
import com.vuzix.ultralite.Layout
import com.vuzix.ultralite.TextAlignment
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** VuzixUltralitePlugin */
class VuzixUltralitePlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var ultraliteSDK: UltraliteSDK
  private var sdkAvailable = true
  private var glassLinked = true
  private var glassConnected = true

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vuzix_ultralite_flutter_plugin")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    ultraliteSDK = UltraliteSDK.get(context)
    ultraliteSDK.setLayout(Layout.CANVAS, 0, true)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> {
        try {
          ultraliteSDK = UltraliteSDK.get(context)
          result.success(true)
        } catch (e: Exception) {
          result.error("INIT_ERROR", "Failed to initialize Vuzix SDK", e.message)
        }
      }
      "connect" -> {
        try {
          if (ultraliteSDK.requestControl()) {
            result.success(true)
          } else {
            result.error("CONNECT_ERROR", "Failed to get control of Vuzix device", null)
          }
        } catch (e: Exception) {
          result.error("CONNECT_ERROR", "Failed to connect to Vuzix device", e.message)
        }
      }
      "disconnect" -> {
        try {
          ultraliteSDK.releaseControl()
          result.success(true)
        } catch (e: Exception) {
          result.error("DISCONNECT_ERROR", "Failed to disconnect from Vuzix device", e.message)
        }
      }
      "sendText" -> {
        try {
          val text = call.argument<String>("text")
          if (text != null) {
            if (ultraliteSDK.requestControl()) {
              ultraliteSDK.sendText(text)
              result.success(true)
            } else {
              result.error("TEXT_ERROR", "Failed to get control of Vuzix device", null)
            }
          } else {
            result.error("TEXT_ERROR", "Text cannot be null", null)
          }
        } catch (e: Exception) {
          result.error("TEXT_ERROR", "Failed to send text to Vuzix device", e.message)
        }
      }
      "checkVuzixStatus" -> {
        val status = mapOf(
          "sdkAvailable" to sdkAvailable,
          "glassLinked" to glassLinked,
          "glassConnected" to glassConnected
        )
        result.success(status)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    ultraliteSDK.releaseControl()
  }
}
