
import 'flutter_car_toon_platform_interface.dart';

class FlutterCarToon {
  Future<String?> getPlatformVersion() {
    return FlutterCarToonPlatform.instance.getPlatformVersion();
  }
}
