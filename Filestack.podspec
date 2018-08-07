Pod::Spec.new do |spec|
  spec.name         = 'Filestack'
  spec.version      = File.read('./VERSION')
  spec.license      = { :type => 'Apache License, Version 2.0"', :file => "LICENSE" }
  spec.homepage     = 'https://github.com/filestack/filestack-ios'
  spec.authors      = { 'Filestack' => 'ios@filestack.com' }
  spec.summary      = 'Official iOS SDK for Filestack.'
  spec.source       = { :git => 'https://github.com/filestack/filestack-ios.git', :tag => spec.version }

  spec.ios.deployment_target  = '9.0'

  spec.source_files = 'Filestack/**/*.{h,swift}'
  spec.resources = ["Filestack/UI/*.storyboard", "Filestack/Resources/*.xcassets"]

  spec.dependency 'Alamofire', '~> 4.6'
  spec.dependency 'FilestackSDK', '~> 1.2.6'
  spec.dependency 'SSZipArchive', '~> 2.1'
end
