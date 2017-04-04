source 'https://github.com/CocoaPods/Specs.git'
workspace 'Filestack.xcworkspace'
xcodeproj 'Filestack.xcodeproj'

target :'FilestackIOS' do
  platform :ios, '8.4'
  pod 'AFNetworking', '~> 3.0'
  pod 'AFNetworkActivityLogger', git: 'https://github.com/AFNetworking/AFNetworkActivityLogger.git', branch: '3_0_0'
end

# Mac Targets

target :'FilestackMac' do
  platform :osx, '10.9'
  pod 'AFNetworking', '~> 3.0'
  pod 'AFNetworkActivityLogger', git: 'https://github.com/AFNetworking/AFNetworkActivityLogger.git', branch: '3_0_0'
end

target :'FilestackIOSTests' do
  platform :ios, '8.4'
  pod 'OHHTTPStubs', '~> 5.0'
  pod 'AFNetworkActivityLogger', git: 'https://github.com/AFNetworking/AFNetworkActivityLogger.git', branch: '3_0_0'
end

target :'FilestackMacTests' do
  platform :osx, '10.9'
  pod 'OHHTTPStubs', '~> 5.0'
  pod 'AFNetworkActivityLogger', git: 'https://github.com/AFNetworking/AFNetworkActivityLogger.git', branch: '3_0_0'
end
