# Uncomment the next line to define a global platform for your project
platform :ios, '10.3'

target 'PicoAdda' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    pod 'MQTTClient'
    pod 'UICircularProgressRing'
    pod 'JSQMessagesViewController', :git => 'https://github.com/Mobifyi/JSQMessagesViewController.git', :branch => 'dv_ola'
    pod 'TextFieldEffects'
    pod 'SwiftyJSON'
    pod 'Kingfisher'
    pod 'couchbase-lite-ios'
    pod 'GooglePlaces'
    pod 'ReachabilitySwift'
    pod 'GooglePlacePicker'
    pod 'libPhoneNumber-iOS', '~> 0.8'
    pod 'SCRecorder'
    pod 'APAddressBook'
    pod 'MarqueeLabel'
    pod 'Gemini'
    pod 'SocketRocket'
    pod 'WebRTC'
    pod 'RxAlamofire'
    pod 'Locksmith'
    pod 'CocoaLumberjack/Swift'
    pod 'RxReachability'
    pod 'ParallaxHeader'
    pod 'TLPhotoPicker', '~> 1.9.4'
    pod 'ACEDrawingView'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'Firebase/DynamicLinks'
    pod 'Firebase/Crashlytics'
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'FBSDKShareKit'
    pod 'GoogleSignIn'
    pod 'OneSignal', '>= 3.0.0', '< 4.0'
    pod 'Google-Mobile-Ads-SDK'

# Recommended: Add the Firebase pod for Google Analytics
    pod 'Firebase/Analytics'
    pod 'EVURLCache', :git => 'https://github.com/Mobifyi/EVURLCache'
    pod 'Cloudinary'
    pod 'DGElasticPullToRefresh'
    pod 'QuiltView'
    pod 'SteviaLayout'
    pod 'CameraBackground'
    pod 'Starscream', '~> 3.1.0'
    pod 'IHKeyboardAvoiding'
    pod 'IQKeyboardManagerSwift'
    pod 'PhoneNumberKit'
    pod 'PixelEngine'
    pod 'PixelEditor'
    pod 'TextAttributes'
    pod 'Stripe'
    pod 'LatLongToTimezone', '~> 1.1'
    pod 'Regift'
    pod 'ijkplayer'
    
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    config.build_settings['ENABLE_BITCODE'] = 'NO'
end
end

    # Pods for MQTT Chat Module
    
    target 'PicoAddaTests' do
        inherit! :search_paths
        # Pods for testing
    end
    target 'PicoAddaUITests' do
        inherit! :search_paths
        # Pods for testing
    end
    
end
