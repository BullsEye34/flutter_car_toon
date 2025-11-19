import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_car_toon_platform_interface.dart';

/// An implementation of [FlutterCarToonPlatform] that uses method channels.
class MethodChannelFlutterCarToon extends FlutterCarToonPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_car_toon');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
