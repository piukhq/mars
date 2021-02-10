# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

inhibit_all_warnings!

def common_pods

pod 'Firebase'
pod 'Firebase/Analytics'
pod 'Firebase/RemoteConfig'
pod 'Alamofire'
pod 'AlamofireImage'
pod 'AlamofireNetworkActivityLogger'
pod 'DeepDiff'
pod 'KeychainAccess'
pod 'Disk'
pod 'DTTJailbreakDetection'
pod 'JWTDecode'
pod 'SwiftyRSA', :git => 'git@git.bink.com:Pantheon/iOS/SwiftyRSA.git'
pod 'ZendeskSupportSDK'
pod 'CardScan', :git => 'git@git.bink.com:Pantheon/iOS/cardscan-ios.git'
pod 'ZXingObjC'
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
end

target 'binkappUITests' do
    inherit! :search_paths
    use_frameworks!
  # Pods for testing
  common_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
