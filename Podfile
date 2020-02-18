# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def common_pods

pod 'Firebase'
pod 'Firebase/Analytics'
pod 'Alamofire', '~> 5.0.0-rc.3'
pod 'SwipeCellKit'
pod 'Fabric'
pod 'Crashlytics'
pod 'AlamofireImage', '~> 4.0.0-beta.6'
pod 'iOSDropDown'
pod 'M13Checkbox'
pod 'AlamofireNetworkActivityLogger'
pod 'DeepDiff'
pod 'CryptoSwift'
pod 'KeychainAccess', '~> 4.1'
pod 'FacebookSDK', '~> 5.9'
pod 'FBSDKLoginKit', '~> 5.8'
pod 'Disk'
pod 'JWTDecode', '~> 2.4'

plugin 'cocoapods-keys', {
  :project => "binkapp",
  :keys => [
    "baseUrlKey",
    "organisationIdKey",
    "propertyIdKey",
    "bundleIdKey",
    "secretKey",
    "stagingSecretKey",
    "spreedlyEnvironmentKey"
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
