//
//  AppDelegate.swift
//  chatter_client_ios
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit
import UserNotifications
import ReSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, StoreSubscriber {
    
    typealias StoreSubscriberStateType = AppState
    
    var window: UIWindow?
    var unreadMessages: Int = 0
    let msgCenter = MessageCenter(host: "192.168.0.214", port: 8080, endpoint: "websocket")
    let tester = MessageCenterTests(msgCenter:MessageCenter(host: "192.168.0.214", port: 8080, endpoint: "websocket"))
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let center  = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge,.alert], completionHandler: { (granted,error) in
            if granted {
                Logger.log(level:LogLevel.DEBUG,message:"Granted access to send local notifications",
                           className:"AppDelegate",methodName:"didFinishiLaunchingWithOptions")
            }
        })
        msgCenter.run()
        appStore.subscribe(self)
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
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        tester.play()
        completionHandler(.newData)
    }
    
    /**
     * Method starts every time when application state changes
     *
     * - Parameter state: New application state
     */
    func newState(state: AppState) {
        let new_messages_count = ChatMessage.getUnreadCount()
        if new_messages_count != unreadMessages {
            let last_message = appStore.state.chat.messages[0]
            let message = UNMutableNotificationContent()
            message.title = "\(last_message.from_user.login) writing"
            message.body = last_message.text
            message.badge = NSNumber(integerLiteral: new_messages_count)
            message.categoryIdentifier = "MESSAGE_RECEIVED"
            UIApplication.shared.applicationIconBadgeNumber = new_messages_count
            let request = UNNotificationRequest(identifier: "NewMessage", content:message,trigger:nil)
            let center = UNUserNotificationCenter.current()
            center.add(request)  { (error:Error?) in
                if let theError = error {
                    Logger.log(level:LogLevel.WARNING,message:"Could not send notification \(message). " +
                        "Error: \(theError.localizedDescription)",className:"AppDelegate",methodName:"newState")
                } else {
                    Logger.log(level:LogLevel.DEBUG,message:"Sent notification \(message)",
                        className:"AppDelegate",methodName:"newState")
                }
            }
        }
        unreadMessages = new_messages_count
    }
}
