//
//  TrackingProgress.swift
//  Filestack
//
//  Created by Ruben Nine on 07/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

class TrackingProgress: Progress, @unchecked Sendable {
    // MARK: - Private Properties

    private let lockQueue = DispatchQueue(label: "com.filestack.FilestackSDK.tracking-progress-lock-queue")

    private var observers: [NSKeyValueObservation] = []

    private var _tracked: Progress? {
        didSet {
            removeObservers()

            guard let progress = _tracked else { return }

            kind = progress.kind
            fileOperationKind = progress.fileOperationKind
            fileTotalCount = progress.fileTotalCount
            fileCompletedCount = progress.fileCompletedCount
            fileURL = progress.fileURL
            totalUnitCount = progress.totalUnitCount
            completedUnitCount = progress.completedUnitCount

            setupObservers()
        }
    }

    // MARK: - Lifecycle

    required init(tracked progress: Progress? = nil) {
        super.init(parent: nil, userInfo: nil)

        if let tracked = tracked {
            update(tracked: tracked)
        }
    }
}

// MARK: - Computed Properties

private extension TrackingProgress {
    var tracked: Progress? {
        get { lockQueue.sync { _tracked } }
        set { lockQueue.sync { _tracked = newValue } }
    }
}

// MARK: - Internal Functions

extension TrackingProgress {
    func update(tracked progress: Progress?, delay: Double = 0) {
        let delay: Double = tracked == nil ? 0 : delay // ignore `delay` argument if there's currently no tracked progress.

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard !self.isCancelled else { return }
            self.tracked = progress
        }
    }

    override func cancel() {
        super.cancel()

        tracked = nil
    }
}

// MARK: - Progress Overrides

extension TrackingProgress {
    override var localizedDescription: String! {
        get { tracked?.localizedDescription ?? super.localizedDescription }
        set { /* */ }
    }

    override var localizedAdditionalDescription: String! {
        get { tracked?.localizedAdditionalDescription ?? super.localizedAdditionalDescription }
        set { /* */ }
    }
}

// MARK: - Private Functions

private extension TrackingProgress {
    func setupObservers() {
        guard let tracked = _tracked else { return }

        observers.append(tracked.observe(\.totalUnitCount, options: [.new]) { (progress, change) in
            self.totalUnitCount = progress.totalUnitCount
        })

        observers.append(tracked.observe(\.completedUnitCount, options: [.new]) { (progress, change) in
            self.completedUnitCount = progress.completedUnitCount
        })
    }

    func removeObservers() {
        observers.removeAll()
    }
}
