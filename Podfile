# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def common_pods

pod 'Firebase'
pod 'GoogleSignIn'
pod 'Intercom'
pod 'Swinject'
pod 'Alamofire'
pod 'SwipeCellKit'
pod 'Fabric'
pod 'Crashlytics'
pod 'AlamofireImage'
pod 'iOSDropDown'
pod 'M13Checkbox'
pod 'AlamofireNetworkActivityLogger'
pod 'DeepDiff'

plugin 'cocoapods-keys', {
  :project => "binkapp",
  :keys => [
    "baseUrlKey",
    "organisationIdKey",
    "propertyIdKey",
    "bundleIdKey",
    "secretKey",
    "stagingSecretKey"
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
