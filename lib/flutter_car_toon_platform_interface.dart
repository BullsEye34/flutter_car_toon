import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_car_toon_method_channel.dart';

abstract class FlutterCarToonPlatform extends PlatformInterface {
  /// Constructs a FlutterCarToonPlatform.
  FlutterCarToonPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterCarToonPlatform _instance = MethodChannelFlutterCarToon();

  /// The default instance of [FlutterCarToonPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterCarToon].
  static FlutterCarToonPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterCarToonPlatform] when
  /// they register themselves.
  static set instance(FlutterCarToonPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
