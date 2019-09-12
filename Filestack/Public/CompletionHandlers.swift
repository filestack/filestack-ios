//
//  CompletionHandlers.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// :nodoc:
public typealias FolderListCompletionHandler = (_ response: FolderListResponse) -> Swift.Void

/// :nodoc:
public typealias StoreCompletionHandler = (_ response: StoreResponse) -> Swift.Void

/// :nodoc:
public typealias LogoutCompletionHandler = (_ response: LogoutResponse) -> Swift.Void

/// :nodoc:
public typealias PrefetchCompletionHandler = (_ response: PrefetchResponse) -> Swift.Void
