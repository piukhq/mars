# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

inhibit_all_warnings!

def common_pods

pod 'Firebase'
pod 'Firebase/Analytics'
pod 'Alamofire', '~> 5.0.0-rc.3'
pod 'AlamofireImage', '~> 4.0.0-beta.6'
pod 'M13Checkbox'
pod 'AlamofireNetworkActivityLogger'
pod 'DeepDiff'
pod 'CryptoSwift'
pod 'KeychainAccess', '~> 4.1'
pod 'FacebookSDK', '~> 6.0.0'
pod 'FBSDKLoginKit', '~> 6.0.0'
pod 'Disk'
pod 'DTTJailbreakDetection'
pod 'JWTDecode', '~> 2.4'
pod 'SwiftyRSA', :git => 'git@git.bink.com:Pantheon/iOS/SwiftyRSA.git'
pod 'ZendeskSupportSDK'

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
    "zendeskProductionUrl"
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
