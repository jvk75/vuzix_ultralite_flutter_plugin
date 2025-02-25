import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'vuzix_z100_plugin_method_channel.dart';

abstract class VuzixZ100PluginPlatform extends PlatformInterface {
  /// Constructs a VuzixZ100PluginPlatform.
  VuzixZ100PluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static VuzixZ100PluginPlatform _instance = MethodChannelVuzixZ100Plugin();

  /// The default instance of [VuzixZ100PluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelVuzixZ100Plugin].
  static VuzixZ100PluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VuzixZ100PluginPlatform] when
  /// they register themselves.
  static set instance(VuzixZ100PluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<bool> connect() {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<bool> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<Map<String, dynamic>> getDeviceInfo() {
    throw UnimplementedError('getDeviceInfo() has not been implemented.');
  }

  Future<bool> sendText(String text) {
    throw UnimplementedError('sendText() has not been implemented.');
  }

  Future<bool> clearDisplay() {
    throw UnimplementedError('clearDisplay() has not been implemented.');
  }

  Stream<String> get connectionStateChanges {
    throw UnimplementedError('connectionStateChanges has not been implemented.');
  }

  Stream<Map<String, dynamic>> get deviceEvents {
    throw UnimplementedError('deviceEvents has not been implemented.');
  }
}
