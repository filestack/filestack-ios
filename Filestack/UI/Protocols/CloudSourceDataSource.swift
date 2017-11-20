//
//  CloudSourceDataSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/16/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK


protocol CloudSourceDataSource: class {

    var filestack: Filestack! { get }
    var storeOptions: StorageOptions! { get }
    var source: CloudSource!  { get }
    var path: String! { get set }
    var nextPageToken: String? { get set }
    var items: [CloudItem]? { get }
    var thumbnailCache: NSCache<NSURL, UIImage> { get }

    func store(item: CloudItem)
    func navigate(to item: CloudItem)
    func loadNextPage(completionHandler: @escaping (() -> Void))
    func refresh(completionHandler: @escaping (() -> Void))
    func cacheThumbnail(for item: CloudItem, completionHandler: @escaping ((UIImage) -> Void))
}
