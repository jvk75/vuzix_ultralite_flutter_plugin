import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('vuzix_ultralite_flutter_plugin');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'initialize':
          case 'connect':
          case 'disconnect':
          case 'sendText':
          case 'clearDisplay':
            return true;
          case 'getDeviceInfo':
            return {
              'batteryLevel': 100,
              'firmwareVersion': '1.0.0',
              'serialNumber': 'TEST123'
            };
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    log.clear();
  });

  test('initialize', () async {
    await channel.invokeMethod<bool>('initialize');
    expect(
      log,
      <Matcher>[isMethodCall('initialize', arguments: null)],
    );
  });

  test('connect', () async {
    await channel.invokeMethod<bool>('connect');
    expect(
      log,
      <Matcher>[isMethodCall('connect', arguments: null)],
    );
  });

  test('disconnect', () async {
    await channel.invokeMethod<bool>('disconnect');
    expect(
      log,
      <Matcher>[isMethodCall('disconnect', arguments: null)],
    );
  });

  test('getDeviceInfo', () async {
    final result = await channel.invokeMethod<Map<String, dynamic>>('getDeviceInfo');
    expect(
      log,
      <Matcher>[isMethodCall('getDeviceInfo', arguments: null)],
    );
    expect(result, {
      'batteryLevel': 100,
      'firmwareVersion': '1.0.0',
      'serialNumber': 'TEST123'
    });
  });

  test('sendText', () async {
    const text = 'Hello World';
    await channel.invokeMethod<bool>('sendText', {'text': text});
    expect(
      log,
      <Matcher>[isMethodCall('sendText', arguments: {'text': text})],
    );
  });

  test('clearDisplay', () async {
    await channel.invokeMethod<bool>('clearDisplay');
    expect(
      log,
      <Matcher>[isMethodCall('clearDisplay', arguments: null)],
    );
  });
}
