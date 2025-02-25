import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'vuzix_ultralite_flutter_plugin_platform_interface.dart';

/// An implementation of [VuzixUltralitePluginPlatform] that uses method channels.
class MethodChannelVuzixUltralitePlugin extends VuzixUltralitePluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vuzix_ultralite_flutter_plugin');

  /// The event channel for connection state changes
  final EventChannel _connectionStateChannel =
      const EventChannel('vuzix_ultralite_flutter_plugin/connection_state');

  /// The event channel for device events
  final EventChannel _deviceEventsChannel =
      const EventChannel('vuzix_ultralite_flutter_plugin/device_events');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> initialize() async {
    final result = await methodChannel.invokeMethod<bool>('initialize');
    return result ?? false;
  }

  @override
  Future<bool> connect() async {
    final result = await methodChannel.invokeMethod<bool>('connect');
    return result ?? false;
  }

  @override
  Future<bool> disconnect() async {
    final result = await methodChannel.invokeMethod<bool>('disconnect');
    return result ?? false;
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('getDeviceInfo');
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Future<bool> sendText(String text) async {
    final result = await methodChannel.invokeMethod<bool>('sendText', {'text': text});
    return result ?? false;
  }

  @override
  Future<bool> clearDisplay() async {
    final result = await methodChannel.invokeMethod<bool>('clearDisplay');
    return result ?? false;
  }

  @override
  Stream<String> get connectionStateChanges {
    return _connectionStateChannel.receiveBroadcastStream().map((event) => event.toString());
  }

  @override
  Stream<Map<String, dynamic>> get deviceEvents {
    return _deviceEventsChannel.receiveBroadcastStream().map((event) {
      if (event is Map<Object?, Object?>) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }
}
