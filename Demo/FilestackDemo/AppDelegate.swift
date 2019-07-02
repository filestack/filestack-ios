//
//  AppDelegate.swift
//  FilestackDemo
//
//  Created by Ruben Nine on 10/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Filestack
import UIKit

// Make sure the app URL scheme matches that one set in your info plist, in this demo this is "filestackdemo".
let appURLScheme = "filestackdemo"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == appURLScheme, url.host == "Filestack" {
            return true
        }

        return false
    }
}
