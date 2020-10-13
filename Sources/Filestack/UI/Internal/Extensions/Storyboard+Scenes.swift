//
//  Storyboard+ instantiateViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit

extension UIStoryboard {
    func instantiateViewController<S: Scene>(for scene: S) -> S.ViewController {
        guard let viewController = instantiateViewController(withIdentifier: scene.identifier) as? S.ViewController else {
            fatalError("expected view controller with identifier '\(scene.identifier)' to be of type '\(String(describing: S.ViewController.self))'")
        }

        scene.configureViewController(viewController)

        return viewController
    }
}
