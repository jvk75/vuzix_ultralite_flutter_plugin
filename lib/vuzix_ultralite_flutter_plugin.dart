import 'dart:async';
import 'package:flutter/services.dart';

/// A Flutter plugin for integrating with Vuzix Ultralite smart glasses.
/// 
/// This plugin provides functionality to connect to Vuzix Ultralite glasses,
/// display text, and receive device events.
class VuzixUltralitePlugin {
  static const MethodChannel _channel = MethodChannel('vuzix_ultralite_flutter_plugin');
  static const EventChannel _connectionStateChannel = EventChannel('vuzix_ultralite_flutter_plugin/connection_state');
  static const EventChannel _deviceEventsChannel = EventChannel('vuzix_ultralite_flutter_plugin/device_events');

  static Stream<String>? _connectionStateStream;
  static Stream<Map<String, dynamic>>? _deviceEventsStream;

  /// Initializes the Vuzix Ultralite SDK.
  /// 
  /// Returns `true` if initialization was successful.
  static Future<bool> initialize() async {
    final bool result = await _channel.invokeMethod('initialize');
    return result;
  }

  /// Shows the device picker and connects to the selected Vuzix device.
  /// 
  /// Returns `true` if connection was successful.
  static Future<bool> connect() async {
    final bool result = await _channel.invokeMethod('connect');
    return result;
  }

  /// Disconnects from the currently connected Vuzix device.
  /// 
  /// Returns `true` if disconnection was successful.
  static Future<bool> disconnect() async {
    final bool result = await _channel.invokeMethod('disconnect');
    return result;
  }

  /// Gets information about the connected device.
  /// 
  /// Returns a map containing device information such as name, ID, and connection status.
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final Map<String, dynamic> result = await _channel.invokeMethod('getDeviceInfo');
    return result;
  }

  /// Sends text to be displayed on the Vuzix device.
  /// 
  /// Returns `true` if the text was sent successfully.
  static Future<bool> sendText(String text) async {
    final bool result = await _channel.invokeMethod('sendText', {'text': text});
    return result;
  }

  /// Clears any text currently displayed on the Vuzix device.
  /// 
  /// Returns `true` if the display was cleared successfully.
  static Future<bool> clearDisplay() async {
    final bool result = await _channel.invokeMethod('clearDisplay');
    return result;
  }

  /// Stream of connection state changes.
  /// 
  /// Emits strings like 'connected', 'disconnected', etc.
  static Stream<String> get connectionState {
    _connectionStateStream ??= _connectionStateChannel
        .receiveBroadcastStream()
        .map<String>((dynamic event) => event as String);
    return _connectionStateStream!;
  }

  /// Stream of device events.
  /// 
  /// Emits maps containing event data from the device.
  static Stream<Map<String, dynamic>> get deviceEvents {
    _deviceEventsStream ??= _deviceEventsChannel
        .receiveBroadcastStream()
        .map<Map<String, dynamic>>((dynamic event) => Map<String, dynamic>.from(event as Map));
    return _deviceEventsStream!;
  }
}
