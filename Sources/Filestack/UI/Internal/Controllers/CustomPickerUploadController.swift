//
//  CustomPickerUploadController.swift
//  CustomPickerUploadController
//
//  Created by Ruben Nine on 26/7/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import FilestackSDK
import UIKit

class CustomPickerUploadController: URLPickerUploadController {
    let navigationVC: UINavigationController
    let provider: SourceProvider

    init(uploader: (Uploader & DeferredAdd)?,
         viewController: UIViewController,
         provider: SourceProvider,
         config: Config,
         context: Any? = nil,
         completionBlock: (([URL]) -> Void)? = nil) {

        self.navigationVC = UINavigationController(rootViewController: provider)
        self.provider = provider

        super.init(uploader: uploader, viewController: viewController, presentedViewController: navigationVC, config: config, completionBlock: completionBlock)

        provider.sourceProviderDelegate = self
    }
}

extension CustomPickerUploadController: SourceProviderDelegate {
    func sourceProviderPicked(urls: [URL]) {
        upload(urls: urls)
        print("Custom SourceProvider Picked urls: \(urls)")
    }

    func sourceProviderCancelled() {
        print("Custom SourceProvider Cancelled.")
    }
}
