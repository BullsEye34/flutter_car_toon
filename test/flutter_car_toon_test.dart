import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_car_toon/flutter_car_toon.dart';
import 'package:flutter_car_toon/flutter_car_toon_platform_interface.dart';
import 'package:flutter_car_toon/flutter_car_toon_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterCarToonPlatform
    with MockPlatformInterfaceMixin
    implements FlutterCarToonPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterCarToonPlatform initialPlatform = FlutterCarToonPlatform.instance;

  test('$MethodChannelFlutterCarToon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterCarToon>());
  });

  test('getPlatformVersion', () async {
    FlutterCarToon flutterCarToonPlugin = FlutterCarToon();
    MockFlutterCarToonPlatform fakePlatform = MockFlutterCarToonPlatform();
    FlutterCarToonPlatform.instance = fakePlatform;

    expect(await flutterCarToonPlugin.getPlatformVersion(), '42');
  });
}
