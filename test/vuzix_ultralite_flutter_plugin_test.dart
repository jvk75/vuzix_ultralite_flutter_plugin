import 'package:flutter_test/flutter_test.dart';
import 'package:vuzix_ultralite_flutter_plugin/vuzix_ultralite_flutter_plugin.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initialize', () async {
    expect(await VuzixUltralitePlugin.initialize(), true);
  });

  test('connect', () async {
    expect(await VuzixUltralitePlugin.connect(), true);
  });

  test('disconnect', () async {
    expect(await VuzixUltralitePlugin.disconnect(), true);
  });

  test('getDeviceInfo', () async {
    final deviceInfo = await VuzixUltralitePlugin.getDeviceInfo();
    expect(deviceInfo, isA<Map<String, dynamic>>());
  });

  test('sendText', () async {
    expect(await VuzixUltralitePlugin.sendText('Hello'), true);
  });

  test('clearDisplay', () async {
    expect(await VuzixUltralitePlugin.clearDisplay(), true);
  });

  test('connectionState stream', () async {
    expect(VuzixUltralitePlugin.connectionState, isA<Stream<String>>());
  });

  test('deviceEvents stream', () async {
    expect(VuzixUltralitePlugin.deviceEvents, isA<Stream<Map<String, dynamic>>>());
  });
}
