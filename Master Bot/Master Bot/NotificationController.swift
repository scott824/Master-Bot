//
//  NotificationController.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 5. 7..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationController {
    
    var contentsController: ContentsController?
    static var weatherNotification: Bool = false
    
    func initNotificationSetupCheck() {
        UNUserNotificationCenter.current().requestAuthorization(options: UNAuthorizationOptions.alert, completionHandler: { success, error in
            if success {
                NSLog("Notification Center request authorization success!")
            } else {
                NSLog("Notification Center request authorization fail!")
            }
        })
    }
    
    func setNotification() {
        NotificationController.weatherNotification = true
        let notification = UNMutableNotificationContent()
        notification.title = "Master Bot"
        notification.subtitle = "오늘의 날씨"
        notification.body = "오늘의 날씨는 맑음"
        
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "weather", content: notification, trigger: notificationTrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            
        })
    }
}
