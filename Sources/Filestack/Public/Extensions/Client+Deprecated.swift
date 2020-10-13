//
//  Client+Deprecated.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import FilestackSDK
import UIKit

extension Client {
    // MARK: - Deprecated

    /// Uploads a file directly to a given storage location (currently only S3 is supported.)
    ///
    /// - Parameter localURL: The URL of the local file to be uploaded.
    /// - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.
    /// If none given, S3 location with default options is assumed.
    /// - Parameter useIntelligentIngestionIfAvailable: Attempts to use Intelligent Ingestion for file uploading.
    /// Defaults to `true`.
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle of the upload process
    /// as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: An `Uploader` that allows starting, cancelling and monitoring the upload.
    @objc
    @available(*, deprecated, message: "Marked for removal in version 3.0. Please use upload(using:options:queue:uploadProgress:completionHandler:) instead")
    @discardableResult
    public func upload(from localURL: URL,
                       storeOptions: StorageOptions = .defaults,
                       useIntelligentIngestionIfAvailable: Bool = true,
                       queue: DispatchQueue = .main,
                       uploadProgress: ((Progress) -> Void)? = nil,
                       completionHandler: @escaping (JSONResponse?) -> Void) -> Uploader {
        let uploadOptions = UploadOptions(preferIntelligentIngestion: useIntelligentIngestionIfAvailable,
                                          startImmediately: true,
                                          storeOptions: storeOptions)

        return upload(using: localURL,
                      options: uploadOptions,
                      queue: queue,
                      uploadProgress: uploadProgress,
                      completionHandler: completionHandler)
    }

    /// Uploads a file to a given storage location picked interactively from the camera or the photo library.
    ///
    /// - Parameter viewController: The view controller that will present the picker.
    /// - Parameter sourceType: The desired source type (e.g. camera, photo library.)
    /// - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.)
    /// If none given, S3 location with default options is assumed.
    /// - Parameter useIntelligentIngestionIfAvailable: Attempts to use Intelligent Ingestion for file uploading.
    /// Defaults to `true`.
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle of the upload process
    /// as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `Cancellable & Monitorizable` that allows cancelling and monitoring the upload.
    @objc
    @available(*, deprecated, message: "Marked for removal in version 3.0. Please use uploadFromImagePicker(viewController:sourceType:options:queue:uploadProgress:completionHandler:) instead")
    @discardableResult
    public func uploadFromImagePicker(viewController: UIViewController,
                                      sourceType: UIImagePickerController.SourceType,
                                      storeOptions: StorageOptions = .defaults,
                                      useIntelligentIngestionIfAvailable: Bool = true,
                                      queue: DispatchQueue = .main,
                                      uploadProgress: ((Progress) -> Void)? = nil,
                                      completionHandler: @escaping ([JSONResponse]) -> Void) -> Cancellable & Monitorizable {
        let uploadOptions = UploadOptions(preferIntelligentIngestion: useIntelligentIngestionIfAvailable,
                                          startImmediately: false,
                                          storeOptions: storeOptions)

        return uploadFromImagePicker(viewController: viewController,
                                     sourceType: sourceType,
                                     options: uploadOptions,
                                     queue: queue,
                                     uploadProgress: uploadProgress,
                                     completionHandler: completionHandler)
    }

    /// Uploads a file to a given storage location picked interactively from the device's documents, iCloud Drive or
    /// other third-party cloud services.
    ///
    /// - Parameter viewController: The view controller that will present the picker.
    /// - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.)
    /// If none given, S3 location with default options is assumed.
    /// - Parameter useIntelligentIngestionIfAvailable: Attempts to use Intelligent Ingestion for file uploading.
    /// Defaults to `true`.
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle of the upload process
    /// as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `Cancellable & Monitorizable` that allows cancelling and monitoring the upload.
    @objc
    @available(*, deprecated, message: "Marked for removal in version 3.0. Please use uploadFromDocumentPicker(viewController:options:queue:uploadProgress:completionHandler:) instead")
    @discardableResult
    public func uploadFromDocumentPicker(viewController: UIViewController,
                                         storeOptions: StorageOptions = .defaults,
                                         useIntelligentIngestionIfAvailable: Bool = true,
                                         queue: DispatchQueue = .main,
                                         uploadProgress: ((Progress) -> Void)? = nil,
                                         completionHandler: @escaping ([JSONResponse]) -> Void) -> Cancellable & Monitorizable {
        let uploadOptions = UploadOptions(preferIntelligentIngestion: useIntelligentIngestionIfAvailable,
                                          startImmediately: false,
                                          storeOptions: storeOptions)

        return uploadFromDocumentPicker(viewController: viewController,
                                        options: uploadOptions,
                                        queue: queue,
                                        uploadProgress: uploadProgress,
                                        completionHandler: completionHandler)
    }
}
