//
//  Client+ObjC.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

extension Client {
    // MARK: - Objective-C Compatibility

    /// Uploads a single local URL directly to a given storage location.
    ///
    /// Currently the only storage location supported is Amazon S3.
    ///
    /// - Important:
    /// If your uploadable can not return a MIME type (e.g. when passing `Data` as the uploadable), you **must** pass
    /// a custom `UploadOptions` with custom `storeOptions` initialized with a `mimeType` that better represents your
    /// uploadable, otherwise `text/plain` will be assumed.
    ///
    /// - Note: This function is made available especially for Objective-C SDK users. If you are using Swift,
    /// you might want to use `upload(using:options:queue:uploadProgress:completionHandler:)` instead.
    ///
    /// - Parameter localURL: The URL of the local file to be uploaded.
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
    /// of the upload process as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the upload request.
    @objc public func uploadURL(using localURL: NSURL,
                                options: UploadOptions = .defaults,
                                queue: DispatchQueue = .main,
                                uploadProgress: ((Progress) -> Void)? = nil,
                                completionHandler: @escaping (NetworkJSONResponse) -> Void) -> CancellableRequest {
        return upload(using: localURL as URL,
                      options: options,
                      queue: queue,
                      uploadProgress: uploadProgress,
                      completionHandler: completionHandler)
    }

    /// Uploads an array of local URLs directly to a given storage location.
    ///
    /// Currently the only storage location supported is Amazon S3.
    ///
    /// - Important:
    /// If your uploadable can not return a MIME type (e.g. when passing `Data` as the uploadable), you **must** pass
    /// a custom `UploadOptions` with custom `storeOptions` initialized with a `mimeType` that better represents your
    /// uploadable, otherwise `text/plain` will be assumed.
    ///
    /// - Note: This function is made available especially for Objective-C SDK users. If you are using Swift,
    /// you might want to use `upload(using:options:queue:uploadProgress:completionHandler:)` instead.
    ///
    /// - Parameter localURLs: The URL of the local file to be uploaded.
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
    /// of the upload process as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the upload request.
    @objc public func uploadMultipleURLs(using localURLs: [NSURL],
                                         options: UploadOptions = .defaults,
                                         queue: DispatchQueue = .main,
                                         uploadProgress: ((Progress) -> Void)? = nil,
                                         completionHandler: @escaping ([NetworkJSONResponse]) -> Void) -> CancellableRequest {
        return upload(using: localURLs.map { $0 as URL },
                      options: options,
                      queue: queue,
                      uploadProgress: uploadProgress,
                      completionHandler: completionHandler)
    }

    /// Uploads data directly to a given storage location.
    ///
    /// Currently the only storage location supported is Amazon S3.
    ///
    /// - Important:
    /// If your uploadable can not return a MIME type (e.g. when passing `Data` as the uploadable), you **must** pass
    /// a custom `UploadOptions` with custom `storeOptions` initialized with a `mimeType` that better represents your
    /// uploadable, otherwise `text/plain` will be assumed.
    ///
    /// - Note: This function is made available especially for Objective-C SDK users. If you are using Swift,
    /// you might want to use `upload(using:options:queue:uploadProgress:completionHandler:)` instead.
    ///
    /// - Parameter data: The data to be uploaded.
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
    /// of the upload process as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the upload request.
    @objc public func uploadData(using data: NSData,
                                 options: UploadOptions = .defaults,
                                 queue: DispatchQueue = .main,
                                 uploadProgress: ((Progress) -> Void)? = nil,
                                 completionHandler: @escaping (NetworkJSONResponse) -> Void) -> CancellableRequest {
        return upload(using: data as Data,
                      options: options,
                      queue: queue,
                      uploadProgress: uploadProgress,
                      completionHandler: completionHandler)
    }

    /// Uploads multiple data directly to a given storage location.
    ///
    /// Currently the only storage location supported is Amazon S3.
    ///
    /// - Important:
    /// If your uploadable can not return a MIME type (e.g. when passing `Data` as the uploadable), you **must** pass
    /// a custom `UploadOptions` with custom `storeOptions` initialized with a `mimeType` that better represents your
    /// uploadable, otherwise `text/plain` will be assumed.
    ///
    /// - Note: This function is made available especially for Objective-C SDK users.
    /// If you are using Swift, you might want to use `add(uploadables:)` instead.
    ///
    /// - Parameter multipleData: The array of data objects to be uploaded.
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
    /// of the upload process as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the upload request.
    @objc public func uploadMultipleData(using multipleData: [NSData],
                                         options: UploadOptions = .defaults,
                                         queue: DispatchQueue = .main,
                                         uploadProgress: ((Progress) -> Void)? = nil,
                                         completionHandler: @escaping ([NetworkJSONResponse]) -> Void) -> CancellableRequest {
        return upload(using: multipleData.map { $0 as Data },
                      options: options,
                      queue: queue,
                      uploadProgress: uploadProgress,
                      completionHandler: completionHandler)
    }
}
