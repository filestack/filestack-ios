//
//  UIViewController+PresentAlert.swift
//  FilestackDemo
//
//  Created by Ruben Nine on 16/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlert(titled title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: false, completion: nil)
    }
}
