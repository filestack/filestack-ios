//
//  AppDelegate.swift
//  FilestackDemo
//
//  Created by Ruben Nine on 10/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit
import Filestack


// Make sure the app URL scheme matches that one set in your info plist, in this demo this is "filestackdemo".
let appURLScheme = "filestackdemo"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        if url.scheme == appURLScheme && url.host == "Filestack" {
            if #available(iOS 11.0, *) {
                // NO-OP
            } else {
                NotificationCenter.default.post(name: Filestack.Client.resumeCloudRequestNotification, object: url)
            }

            return true
        }

        return false
    }
}
