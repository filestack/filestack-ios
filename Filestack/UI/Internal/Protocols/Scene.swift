//
//  Scene.swift
//  Filestack
//
//  Created by Ruben Nine on 11/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

protocol Scene {
    associatedtype ViewController

    var identifier: String { get }

    func configureViewController(_ viewController: ViewController)
}
