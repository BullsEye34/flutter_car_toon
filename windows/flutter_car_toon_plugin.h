#ifndef FLUTTER_PLUGIN_FLUTTER_CAR_TOON_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_CAR_TOON_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_car_toon {

class FlutterCarToonPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterCarToonPlugin();

  virtual ~FlutterCarToonPlugin();

  // Disallow copy and assign.
  FlutterCarToonPlugin(const FlutterCarToonPlugin&) = delete;
  FlutterCarToonPlugin& operator=(const FlutterCarToonPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_car_toon

#endif  // FLUTTER_PLUGIN_FLUTTER_CAR_TOON_PLUGIN_H_
