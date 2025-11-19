#include "include/flutter_car_toon/flutter_car_toon_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_car_toon_plugin.h"

void FlutterCarToonPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_car_toon::FlutterCarToonPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
