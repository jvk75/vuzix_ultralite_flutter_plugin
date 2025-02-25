package com.loitsut.vuzix_z100_plugin

import android.content.Context
import androidx.annotation.NonNull
import com.vuzix.ultralite.sdk.VuzixUltraliteSDK
import com.vuzix.ultralite.sdk.VuzixUltraliteSDKListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class VuzixZ100Plugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var connectionStateChannel: EventChannel
  private lateinit var deviceEventsChannel: EventChannel
  private lateinit var context: Context
  private lateinit var sdk: VuzixUltraliteSDK
  private var connectionStateEventSink: EventChannel.EventSink? = null
  private var deviceEventsEventSink: EventChannel.EventSink? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vuzix_z100_plugin")
    connectionStateChannel = EventChannel(flutterPluginBinding.binaryMessenger, "vuzix_z100_plugin/connection_state")
    deviceEventsChannel = EventChannel(flutterPluginBinding.binaryMessenger, "vuzix_z100_plugin/device_events")
    
    channel.setMethodCallHandler(this)
    setupEventChannels()
  }

  private fun setupEventChannels() {
    connectionStateChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        connectionStateEventSink = events
      }

      override fun onCancel(arguments: Any?) {
        connectionStateEventSink = null
      }
    })

    deviceEventsChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        deviceEventsEventSink = events
      }

      override fun onCancel(arguments: Any?) {
        deviceEventsEventSink = null
      }
    })
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "initialize" -> {
        try {
          sdk = VuzixUltraliteSDK(context)
          sdk.setListener(object : VuzixUltraliteSDKListener {
            override fun onConnectionStateChanged(state: Int) {
              connectionStateEventSink?.success(when(state) {
                VuzixUltraliteSDK.STATE_DISCONNECTED -> "disconnected"
                VuzixUltraliteSDK.STATE_CONNECTING -> "connecting"
                VuzixUltraliteSDK.STATE_CONNECTED -> "connected"
                else -> "unknown"
              })
            }

            override fun onDeviceEvent(event: Map<String, Any>) {
              deviceEventsEventSink?.success(event)
            }
          })
          result.success(true)
        } catch (e: Exception) {
          result.error("INIT_ERROR", e.message, null)
        }
      }
      "connect" -> {
        try {
          sdk.connect()
          result.success(true)
        } catch (e: Exception) {
          result.error("CONNECT_ERROR", e.message, null)
        }
      }
      "disconnect" -> {
        try {
          sdk.disconnect()
          result.success(true)
        } catch (e: Exception) {
          result.error("DISCONNECT_ERROR", e.message, null)
        }
      }
      "getDeviceInfo" -> {
        try {
          val info = sdk.deviceInfo
          result.success(mapOf(
            "batteryLevel" to info.batteryLevel,
            "firmwareVersion" to info.firmwareVersion,
            "serialNumber" to info.serialNumber
          ))
        } catch (e: Exception) {
          result.error("DEVICE_INFO_ERROR", e.message, null)
        }
      }
      "sendText" -> {
        try {
          val text = call.argument<String>("text") ?: throw Exception("Text argument is required")
          sdk.sendText(text)
          result.success(true)
        } catch (e: Exception) {
          result.error("SEND_TEXT_ERROR", e.message, null)
        }
      }
      "clearDisplay" -> {
        try {
          sdk.clearDisplay()
          result.success(true)
        } catch (e: Exception) {
          result.error("CLEAR_DISPLAY_ERROR", e.message, null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    connectionStateChannel.setStreamHandler(null)
    deviceEventsChannel.setStreamHandler(null)
  }
}
