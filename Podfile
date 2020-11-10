# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

inhibit_all_warnings!

def common_pods

pod 'Firebase'
pod 'Firebase/Analytics'
pod 'Firebase/RemoteConfig'
pod 'Alamofire', '~> 5.0.0-rc.3'
pod 'AlamofireImage', '~> 4.0.0-beta.6'
pod 'AlamofireNetworkActivityLogger'
pod 'DeepDiff'
pod 'KeychainAccess', '~> 4.1'
pod 'FacebookSDK', '~> 6.0.0'
pod 'FBSDKLoginKit', '~> 6.0.0'
pod 'Disk'
pod 'DTTJailbreakDetection'
pod 'JWTDecode', '~> 2.4'
pod 'SwiftyRSA', :git => 'git@git.bink.com:Pantheon/iOS/SwiftyRSA.git'
pod 'ZendeskSupportSDK'
pod 'CardScan', :git => 'git@git.bink.com:Pantheon/iOS/cardscan-ios.git'
pod 'ZXingObjC', '~> 3.6.5'
pod 'SwiftLint'

plugin 'cocoapods-keys', {
  :project => "binkapp",
  :keys => [
    "baseUrlKey",
    "organisationIdKey",
    "propertyIdKey",
    "bundleIdKey",
    "secretKey",
    "stagingSecretKey",
    "spreedlyEnvironmentKey",
    "devPaymentCardHashingSecret1",
    "stagingPaymentCardHashingSecret1",
    "prodPaymentCardHashingSecret1",
    "zendeskSandboxAppId",
    "zendeskSandboxClientId",
    "zendeskSandboxUrl",
    "zendeskProductionAppId",
    "zendeskProductionClientId",
    "zendeskProductionUrl",
    "bouncerPaymentCardScanningKeyDev",
    "bouncerPaymentCardScanningKeyProduction"
  ]
}

end

target 'binkapp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for binkapp
  common_pods

  target 'binkappTests' do
    inherit! :search_paths
    # Pods for testing
    common_pods
  end

  target 'binkappUITests' do
    inherit! :search_paths
    # Pods for testing
    common_pods
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
    end
  end
end
