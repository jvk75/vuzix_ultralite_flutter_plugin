Pod::Spec.new do |s|
  s.name             = 'vuzix_ultralite_flutter_plugin'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin for Vuzix Ultralite SDK'
  s.description      = <<-DESC
Flutter plugin for integrating Vuzix Ultralite SDK to communicate with Vuzix smart glasses.
                       DESC
  s.homepage         = 'https://github.com/loitsut/vuzix_ultralite_flutter_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Loitsut' => 'info@loitsut.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  s.vendored_frameworks = ['UltraliteSDK.xcframework']
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
