//
//  FilestackTests.swift
//  FilestackTests
//
//  Created by Ruben Nine on 10/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import Filestack
import FilestackSDK
import OHHTTPStubs


class FilestackUploadTests: XCTestCase {

    private let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    override func tearDown() {

        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    // MARK: - Tests

    func testRegularUpload() {

        var hitCount = 0

        stubMultipartStartRequest(supportsIntelligentIngestion: false)
        stubMultipartPostPartRequest(parts: ["PART-1"], hitCount: &hitCount)
        stubMultipartPutRequest(part: "PART-1")
        stubMultipartCompleteRequest()

        let security = Seeds.Securities.basic
        let filestack = Filestack.Client(apiKey: "MY-OTHER-API-KEY", security: security)
        let localURL = Bundle(for: type(of: self)).url(forResource: "large", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should succeed")

        var response: NetworkJSONResponse?

        filestack.upload(from: localURL, useIntelligentIngestionIfAvailable: false) { (resp) in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(hitCount, 1)
        XCTAssertEqual(response?.json?["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["size"] as? Int, 6034668)
        XCTAssertEqual(response?.json?["filename"] as? String, "large.jpg")
        XCTAssertEqual(response?.json?["status"] as? String, "Stored")
        XCTAssertEqual(response?.json?["url"] as? String, "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["mimetype"] as? String, "image/jpeg")
    }

    func testResumableUpload() {

        let chunkSize = 1 * Int(pow(Double(1024), Double(2)))
        let partSize = 8 * Int(pow(Double(1024), Double(2)))
        var currentPart = 1
        var currentOffset = 0

        stubMultipartStartRequest(supportsIntelligentIngestion: true)

        let uploadMultipartPostPartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/upload") &&
            isMethodPOST()

        stub(condition: uploadMultipartPostPartStubConditions) { _ in
            let json: [String: Any] = [
                "location_url": "upload-eu-west-1.filestackapi.com",
                "url": "https://s3.amazonaws.com/PART-\(currentPart)/\(currentOffset)",
                "headers": [
                    "Authorization":
                        "AWS4-HMAC-SHA256 Credential=AKIAIBGGXL3I2XTGV4IQ/20170726/us-east-1/s3/aws4_request, " +
                            "SignedHeaders=content-length;content-md5;host;x-amz-date, " +
                    "Signature=6638349931141536177e23f93b4eade99113ccc27ff96cc414b90dee260841c2",
                    "Content-MD5": "yWCet0EAi8FVbzQfk3oofg==",
                    "x-amz-content-sha256": "UNSIGNED-PAYLOAD",
                    "x-amz-date": "20170726T095615Z"
                ]
            ]

            currentOffset += chunkSize

            if currentOffset >= partSize {
                currentOffset = 0
                currentPart += 1
            }

            let headers = ["Content-Type": "application/json"]

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }

        stubMultipartPutRequest()
        stubMultipartCommitRequest()
        stubMultipartCompleteRequest()

        let security = Seeds.Securities.basic
        let filestack = Filestack.Client(apiKey: "MY-OTHER-API-KEY", security: security)
        let localURL = Bundle(for: type(of: self)).url(forResource: "large", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should succeed")
        let progressExpectation = self.expectation(description: "request should succeed")

        var response: NetworkJSONResponse?

        let progressHandler: ((Progress) -> Void) = { progress in
            if progress.completedUnitCount == 6034668 {
                progressExpectation.fulfill()
            }
        }

        filestack.upload(from: localURL,
                         useIntelligentIngestionIfAvailable: true,
                         uploadProgress: progressHandler) { (resp) in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(response?.json?["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["size"] as? Int, 6034668)
        XCTAssertEqual(response?.json?["filename"] as? String, "large.jpg")
        XCTAssertEqual(response?.json?["status"] as? String, "Stored")
        XCTAssertEqual(response?.json?["url"] as? String, "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["mimetype"] as? String, "image/jpeg")
    }

    func testCancellingResumableUpload() {

        let chunkSize = 1 * Int(pow(Double(1024), Double(2)))
        let partSize = 8 * Int(pow(Double(1024), Double(2)))
        var currentPart = 1
        var currentOffset = 0

        stubMultipartStartRequest(supportsIntelligentIngestion: true)

        let uploadMultipartPostPartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/upload") &&
            isMethodPOST()

        stub(condition: uploadMultipartPostPartStubConditions) { _ in
            let json: [String: Any] = [
                "location_url": "upload-eu-west-1.filestackapi.com",
                "url": "https://s3.amazonaws.com/PART-\(currentPart)/\(currentOffset)",
                "headers": [
                    "Authorization":
                        "AWS4-HMAC-SHA256 Credential=AKIAIBGGXL3I2XTGV4IQ/20170726/us-east-1/s3/aws4_request, " +
                            "SignedHeaders=content-length;content-md5;host;x-amz-date, " +
                    "Signature=6638349931141536177e23f93b4eade99113ccc27ff96cc414b90dee260841c2",
                    "Content-MD5": "yWCet0EAi8FVbzQfk3oofg==",
                    "x-amz-content-sha256": "UNSIGNED-PAYLOAD",
                    "x-amz-date": "20170726T095615Z"
                ]
            ]

            currentOffset += chunkSize

            if currentOffset >= partSize {
                currentOffset = 0
                currentPart += 1
            }

            let headers = ["Content-Type": "application/json"]

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }

        stubMultipartPutRequest()
        stubMultipartCommitRequest()
        stubMultipartCompleteRequest(requestTime: 1.0, responseTime: 5.0)

        let security = Seeds.Securities.basic
        let filestack = Filestack.Client(apiKey: "MY-OTHER-API-KEY", security: security)
        let localURL = Bundle(for: type(of: self)).url(forResource: "large", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should succeed")
        let progressExpectation = self.expectation(description: "request should succeed")

        var response: NetworkJSONResponse?

        let progressHandler: ((Progress) -> Void) = { progress in
            if progress.completedUnitCount == 6034668 {
                progressExpectation.fulfill()
            }
        }

        let upload = filestack.upload(from: localURL,
                                      useIntelligentIngestionIfAvailable: true,
                                      uploadProgress: progressHandler) { (resp) in

            response = resp
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

            upload.cancel()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertNotNil(response?.error)
    }

    func testResumableUploadWithDownNetwork() {

        let uploadMultipartStartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/start") &&
            isMethodPOST()

        stub(condition: uploadMultipartStartStubConditions) { _ in
            let notConnectedError = NSError(domain:NSURLErrorDomain,
                                            code:Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
                                            userInfo:nil)

            return OHHTTPStubsResponse(error: notConnectedError)
        }

        let security = Seeds.Securities.basic
        let filestack = Filestack.Client(apiKey: "MY-OTHER-API-KEY", security: security)
        let localURL = Bundle(for: type(of: self)).url(forResource: "large", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should succeed")

        var response: NetworkJSONResponse?

        filestack.upload(from: localURL,
                         useIntelligentIngestionIfAvailable: true) { (resp) in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertNotNil(response?.error)
    }

    func testResumableUploadWithNetworkDown2() {

        let chunkSize = 1 * Int(pow(Double(1024), Double(2)))
        let partSize = 8 * Int(pow(Double(1024), Double(2)))
        var currentPart = 1
        var currentOffset = 0

        stubMultipartStartRequest(supportsIntelligentIngestion: true)

        let uploadMultipartPostPartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/upload") &&
            isMethodPOST()

        stub(condition: uploadMultipartPostPartStubConditions) { _ in
            let json: [String: Any] = [
                "location_url": "upload-eu-west-1.filestackapi.com",
                "url": "https://s3.amazonaws.com/PART-\(currentPart)/\(currentOffset)",
                "headers": [
                    "Authorization":
                        "AWS4-HMAC-SHA256 Credential=AKIAIBGGXL3I2XTGV4IQ/20170726/us-east-1/s3/aws4_request, " +
                            "SignedHeaders=content-length;content-md5;host;x-amz-date, " +
                    "Signature=6638349931141536177e23f93b4eade99113ccc27ff96cc414b90dee260841c2",
                    "Content-MD5": "yWCet0EAi8FVbzQfk3oofg==",
                    "x-amz-content-sha256": "UNSIGNED-PAYLOAD",
                    "x-amz-date": "20170726T095615Z"
                ]
            ]

            currentOffset += chunkSize

            if currentOffset >= partSize {
                currentOffset = 0
                currentPart += 1
            }

            let headers = ["Content-Type": "application/json"]

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }

        let uploadMultipartPutStubConditions = isScheme("https") &&
            isHost("s3.amazonaws.com") &&
            isMethodPUT()

        stub(condition: uploadMultipartPutStubConditions) { _ in
            let notConnectedError = NSError(domain:NSURLErrorDomain,
                                            code:Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
                                            userInfo:nil)

            return OHHTTPStubsResponse(error: notConnectedError)
        }

        let security = Seeds.Securities.basic
        let filestack = Filestack.Client(apiKey: "MY-OTHER-API-KEY", security: security)
        let localURL = Bundle(for: type(of: self)).url(forResource: "large", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should succeed")

        var response: NetworkJSONResponse?

        filestack.upload(from: localURL,
                         useIntelligentIngestionIfAvailable: true) { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertNotNil(response?.error)
    }

    // MARK: - Helper Functions

    private func stubMultipartStartRequest(supportsIntelligentIngestion: Bool) {

        let uploadMultipartStartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/start") &&
            isMethodPOST()

        stub(condition: uploadMultipartStartStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]

            var json = [
                "location_url": "upload-eu-west-1.filestackapi.com",
                "uri": "/SOME-URI-HERE",
                "upload_id": "SOME-UPLOAD-ID",
                "region": "us-east-1"
            ]

            if supportsIntelligentIngestion {
                json["upload_type"] = "intelligent_ingestion"
            }

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }
    }

    private func stubMultipartPutRequest(part: String? = nil) {

        var uploadMultipartPutPartStubConditions = isScheme("https") &&
            isHost("s3.amazonaws.com") &&
            isMethodPUT()

        if let part = part {
            uploadMultipartPutPartStubConditions = uploadMultipartPutPartStubConditions && isPath("/\(part)")
        }

        stub(condition: uploadMultipartPutPartStubConditions) { _ in
            let headers = [
                "Content-Length": "0",
                "Date": "Wed, 26 Jul 2017 09:16:37 GMT",
                "Etag": "c9609eb741008bc1556f341f937a287e",
                "Server": "AmazonS3",
                "x-amz-id-2": "LxaKVvjp9jAK+ErminkrN8HV0VMOA/Bjkbf4A0cCaDRC6smJZerZqN9PqzRzGfn9p8vvTb6YIfM=",
                "x-amz-request-id": "7D827E4E5CFD2E7A"
            ]

            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: headers)
        }
    }

    private func stubMultipartPostPartRequest(parts: [String], hitCount: inout Int) {

        let partName = parts[hitCount]

        let uploadMultipartPostPartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/upload") &&
            isMethodPOST()

        stub(condition: uploadMultipartPostPartStubConditions) { _ in
            let json: [String: Any] = [
                "location_url": "upload-eu-west-1.filestackapi.com",
                "url": "https://s3.amazonaws.com/\(partName)",
                "headers": [
                    "Authorization":
                        "AWS4-HMAC-SHA256 Credential=AKIAIBGGXL3I2XTGV4IQ/20170726/us-east-1/s3/aws4_request, " +
                            "SignedHeaders=content-length;content-md5;host;x-amz-date, " +
                    "Signature=6638349931141536177e23f93b4eade99113ccc27ff96cc414b90dee260841c2",
                    "Content-MD5": "yWCet0EAi8FVbzQfk3oofg==",
                    "x-amz-content-sha256": "UNSIGNED-PAYLOAD",
                    "x-amz-date": "20170726T095615Z"
                ]
            ]

            let headers = ["Content-Type": "application/json"]

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }

        hitCount += 1
    }

    private func stubMultipartCompleteRequest(requestTime: TimeInterval? = nil,
                                              responseTime: TimeInterval? = nil) {

        let uploadMultipartCompleteStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/complete") &&
            isMethodPOST()

        stub(condition: uploadMultipartCompleteStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]

            let json: [String: Any] = [
                "handle": "6GKA0wnQWO7tKaGu2YXA",
                "size": 6034668,
                "filename": "large.jpg",
                "status": "Stored",
                "url": "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA",
                "mimetype": "image/jpeg"
            ]

            let response = OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)

            if let requestTime = requestTime {
                response.requestTime = requestTime
            }

            if let responseTime = responseTime {
                response.responseTime = responseTime
            }

            return response
        }
    }

    private func stubMultipartCommitRequest() {

        let uploadMultipartCommitStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/commit") &&
            isMethodPOST()

        stub(condition: uploadMultipartCommitStubConditions) { _ in
            let headers = ["Content-Type": "text/plain; charset=utf-8"]

            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: headers)
        }
    }
}

