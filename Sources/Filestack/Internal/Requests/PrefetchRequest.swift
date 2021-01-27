//
//  PrefetchRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 11/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

final class PrefetchRequest {
    // MARK: - Properties

    let apiKey: String

    // MARK: - Lifecyle Functions

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Internal Functions

    func perform(cloudService: CloudService, completionBlock: @escaping PrefetchCompletionHandler) {
        let request = cloudService.prefetchRequest(apiKey: apiKey)

        let task = URLSession.filestackDefault.dataTask(with: request) { (data, response, error) in
            // Parse JSON, or return early with error if unable to parse.
            guard let data = data, let json = data.parseJSON() else {
                let response = PrefetchResponse(error: error)

                DispatchQueue.main.async { completionBlock(response) }

                return
            }

            // Results received — return response with contents
            let response = PrefetchResponse(contents: json, error: error)

            DispatchQueue.main.async { completionBlock(response) }
        }

        task.resume()
    }
}
