//
//  MonitorViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/9/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

final class MonitorViewController: UIViewController {
    // MARK: - Private Properties

    private let progressable: Cancellable & Monitorizable
    private var progressObservers: [NSKeyValueObservation] = []

    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()

        progressView.observedProgress = progressable.progress

        return progressView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator: UIActivityIndicatorView

        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .white)
        }

        activityIndicator.hidesWhenStopped = true

        return activityIndicator
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()

        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        return button
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()

        label.text = progressable.progress.localizedDescription

        return label
    }()

    private lazy var additionalDescriptionLabel: UILabel = {
        let label = UILabel()

        label.text = progressable.progress.localizedAdditionalDescription

        return label
    }()

    // MARK: - Lifecycle

    required init(progressable: Cancellable & Monitorizable) {
        self.progressable = progressable

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Overrides

extension MonitorViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if progressable.progress.isIndeterminate {
            progressView.isHidden = true
            activityIndicator.startAnimating()
        } else {
            progressView.isHidden = false
            activityIndicator.stopAnimating()
        }

        setupObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeObservers()
        progressView.observedProgress = nil
    }
}

// MARK: - Actions

private extension MonitorViewController {
    @IBAction func cancel(_: AnyObject) {
        progressable.cancel()
    }
}

// MARK: - Private Functions

private extension MonitorViewController {
    func setupViews() {
        let stackView = UIStackView(arrangedSubviews:
            [UIView(), UIView(), descriptionLabel, activityIndicator, progressView, additionalDescriptionLabel, UIView(), cancelButton]
        )

        progressView.leadingAnchor.constraint(equalTo: stackView.layoutMarginsGuide.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: stackView.layoutMarginsGuide.trailingAnchor).isActive = true

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 22
        stackView.layoutMargins = .init(top: 22, left: 44, bottom: 22, right: 44)
        stackView.isLayoutMarginsRelativeArrangement = true

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.fill(with: stackView)
    }

    func setupObservers() {
        progressObservers.append(progressable.progress.observe(\.totalUnitCount) { (_, _) in
            DispatchQueue.main.async { self.updateUI() }
        })

        progressObservers.append(progressable.progress.observe(\.completedUnitCount) { (_, _) in
            DispatchQueue.main.async { self.updateUI() }
        })

        progressObservers.append(progressable.progress.observe(\.fractionCompleted) { (_, _) in
            DispatchQueue.main.async { self.updateUI() }
        })
    }

    func updateUI() {
        if progressable.progress.isIndeterminate && !progressView.isHidden {
            UIView.animate(withDuration: 0.25) {
                self.activityIndicator.startAnimating()
                self.progressView.isHidden = true
            }
        }

        if !progressable.progress.isIndeterminate && !activityIndicator.isHidden {
            UIView.animate(withDuration: 0.25) {
                self.activityIndicator.stopAnimating()
                self.progressView.isHidden = false
            }
        }

        descriptionLabel.text = progressable.progress.localizedDescription
        additionalDescriptionLabel.text = progressable.progress.localizedAdditionalDescription
    }

    func removeObservers() {
        progressObservers.removeAll()
    }
}
