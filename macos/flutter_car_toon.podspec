#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_car_toon.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_car_toon'
  s.version          = '0.2.1'
  s.summary          = 'A Flutter plugin for parsing and formatting TOON files.'
  s.description      = <<-DESC
A comprehensive TOON (Token-Oriented Object Notation) formatter plugin for Flutter/Dart with all the functionality of dart:convert's JSON library but for TOON format.
                       DESC
  s.homepage         = 'https://github.com/BullsEye34/flutter_car_toon'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'BullsEye34' => 'https://github.com/BullsEye34' }

  s.source           = { :git => 'https://github.com/BullsEye34/flutter_car_toon.git', :tag => s.version.to_s }
  s.source_files = 'flutter_car_toon/Sources/flutter_car_toon/**/*.swift'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_car_toon_privacy' => ['flutter_car_toon/Sources/flutter_car_toon/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
