# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target ‘Gameplan’ do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Gameplan
  pod 'Material', '~> 2.0'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/AdMob'
  pod 'Firebase/Crash'
  pod 'Firebase/Storage'
  pod 'FBSDKLoginKit'
  pod 'FirebaseUI'
  pod 'IQKeyboardManagerSwift'
  pod ‘Fabric’
  pod 'CardsStack', '0.2.1'
  pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git', :branch => 'master'
  pod ‘Digits’
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
