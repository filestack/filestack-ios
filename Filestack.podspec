Pod::Spec.new do |s|
  s.name         = 'Filestack'
  s.version      = '0.2.9'
  s.summary      = 'SDK to access Filestack API'

  s.description  = <<-DESC
    Upload images and files of any kind. Transform them into different styles and formats. Deliver them rapidly and responsively to the world.
  DESC

  s.homepage     = 'https://github.com/filepicker/filestack-ios'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Filestack' => 'lukasz@filestack.com' }

  s.source       = {
    :git => 'https://github.com/filestack/filestack-ios.git',
    :tag => "#{s.version}"
  }

  s.ios.deployment_target = '8.4'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  shared_public_header_files = %w(
    Filestack/Shared/Filestack.h
    Filestack/Shared/Filestack+FSPicker.h
    Filestack/Shared/Models/FSBlob.h
    Filestack/Shared/Models/FSMetadata.h
    Filestack/Shared/Options/FSSecurity.h
    Filestack/Shared/Options/FSStatOptions.h
    Filestack/Shared/Options/FSStoreOptions.h
    Filestack/Shared/Transformations/*.h
  )

  shared_private_transformations_header = %w(
    Filestack/Shared/Transformations/*+Private.h*
  )

  s.ios.public_header_files = %w(
    Filestack/Platform/iOS/FilestackIOS.h
  ).concat(shared_public_header_files)

  s.osx.public_header_files = %w(
    Filestack/Platform/Mac/FilestackMac.h
  ).concat(shared_public_header_files)

  s.ios.private_header_files = shared_private_transformations_header
  s.osx.private_header_files = shared_private_transformations_header

  shared_source_files = %w(
    Filestack/Shared/*.{h,m}
    Filestack/Shared/Options/*.{h,m}
    Filestack/Shared/Models/*.{h,m}
    Filestack/Shared/API/*.{h,m}
    Filestack/Shared/Transformations/*.{h,m}
  )

  s.ios.source_files = %w(Filestack/Platforms/iOS/*.{h,m}).concat(shared_source_files)
  s.osx.source_files = %w(Filestack/Platforms/Mac/*.{h,m}).concat(shared_source_files)

  s.dependency 'AFNetworking', '~> 3.0'
end
