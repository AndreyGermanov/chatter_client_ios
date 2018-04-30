//
//  AppDelegate.swift
//  chatter_client_ios
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let msgCenter = MessageCenter(host: "192.168.0.214", port: 8080, endpoint: "websocket")
    let tester = MessageCenterTests(msgCenter:MessageCenter(host: "192.168.0.214", port: 8080, endpoint: "websocket"))
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        msgCenter.run()
        if let user_id = UserDefaults.standard.string(forKey: "user_id") {
            if let session_id = UserDefaults.standard.string(forKey: "session_id") {
                LoginFormState.loginUserAction().exec(user_id: user_id, session_id: session_id)
            }
        }       
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
