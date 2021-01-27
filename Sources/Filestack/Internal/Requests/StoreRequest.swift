//
//  StoreRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 10/27/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

final class StoreRequest: CloudRequest, Cancellable, Monitorizable {
    // MARK: - Properties

    let apiKey: String
    let security: Security?
    let provider: CloudProvider
    let path: String
    let storeOptions: StorageOptions

    private(set) var token: String?
    private weak var dataTask: URLSessionDataTask?

    let progress: Progress = {
        let progress = Progress(totalUnitCount: 0)

        progress.localizedDescription = "Storing file in storage location…"
        progress.localizedAdditionalDescription = ""

        return progress
    }()

    // MARK: - Lifecyle Functions

    init(apiKey: String,
         security: Security? = nil,
         token: String? = nil,
         provider: CloudProvider,
         path: String,
         storeOptions: StorageOptions) {
        self.apiKey = apiKey
        self.security = security
        self.token = token
        self.provider = provider
        self.path = path
        self.storeOptions = storeOptions
    }

    // MARK: - Cancellable Protocol Implementation

    @discardableResult func cancel() -> Bool {
        guard let dataTask = dataTask else { return false }
        dataTask.cancel()

        return true
    }

    // MARK: - Internal Functions

    func perform(cloudService: CloudService, completionBlock: @escaping CloudRequestCompletion) -> URLSessionDataTask {
        let request = cloudService.storeRequest(provider: provider,
                                                path: path,
                                                apiKey: apiKey,
                                                security: security,
                                                token: token,
                                                storeOptions: storeOptions)

        let task = URLSession.filestackDefault.dataTask(with: request) { (data, response, error) in
            // Parse JSON, or return early with error if unable to parse.
            guard let data = data, let json = data.parseJSON() else {
                let response = StoreResponse(error: error)

                DispatchQueue.main.async { completionBlock(nil, response) }

                return
            }

            // Store any token we receive so we can use it next time.
            self.token = json["token"] as? String

            if let results = self.getResults(from: json) {
                // Results received — return response with contents
                let response = StoreResponse(contents: results, error: error)

                DispatchQueue.main.async { completionBlock(nil, response) }
            }
        }

        dataTask = task

        task.resume()

        return task
    }
}
