//
//  RepItem.swift
//  ReplaceMe
//
//  Created by Cesar Fuentes on 5/18/21.
//

import RealmSwift
import UIKit

class RepItem: Object {
    

    // MARK: PROPERTIES


    @objc dynamic var name: String
    @objc dynamic var months: Int
    @objc dynamic var weeks: Int
    @objc dynamic var days: Int
    @objc dynamic var daysReminder: Int
    @objc dynamic var lastReplaced: Date
    @objc dynamic var nextReplaced: Date
    @objc dynamic var daysItLasts: Int
    @objc dynamic var ratio: Double
    @objc dynamic var short: String
    @objc dynamic var uuid: String
        
    
    // MARK: INITIALIZERS
    
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    required override init() {
        name = ""
        months = 0
        weeks = 0
        days = 0
        daysReminder = 0
        lastReplaced = Date()
        nextReplaced = Date()
        daysItLasts = 0
        ratio = 0.0
        short = ""
        uuid = ""
        super.init()
    }

    convenience init?(name: String, date: Date, months: Int, weeks: Int, days: Int, daysReminder: Int) { //
        self.init()
        self.name = name
        self.months = months
        self.weeks = weeks
        self.days = days
        self.daysReminder = daysReminder
        self.lastReplaced = date
        self.updateNextReplaced()
        daysItLasts = Int(Double((Calendar.current.dateComponents([.day], from: self.lastReplaced, to: self.nextReplaced).day ?? 0)))
        self.updateRatioAbb()
        self.createReminder()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: METHODS

    
    func updateNextReplaced() {
        var dateComponent = DateComponents()
        dateComponent.day = days + (7*weeks)
        dateComponent.month = months
        self.nextReplaced = Calendar.current.date(byAdding: dateComponent, to: lastReplaced)!
    }

    func updateRatioAbb() {
        // update ratio
        let daysLeftInUse = Double((Calendar.current.dateComponents([.day], from: Date(), to: self.nextReplaced).day ?? 0)) + 1
        self.ratio = daysLeftInUse / Double(daysItLasts)
        // update abbrieviation
        let daysLeft = ceil(daysLeftInUse)
        if (daysLeft/365 > 1) && (daysLeft.remainder(dividingBy: 365) > 183) {
            self.short = String(Int(ceil(daysLeft/365))) + " Years" // rounds up >6 months to 1 year
        } else if (daysLeft/365 > 1) {
            self.short = String(Int(floor(daysLeft/365))) + " Years"
        } else if (daysLeft/365 == 1) {
            self.short = String(Int(daysLeft/365)) + " Year"
        } else if (daysLeft/30 > 1) && (daysLeft.remainder(dividingBy: 30) > 14) {
            self.short = String(Int(ceil(daysLeft/30))) + " Months" // rounds up >2 weeks to 1 month
        } else if (daysLeft/30 > 1) {
            self.short = String(Int(floor(daysLeft/30))) + " Months"
        } else if (daysLeft/30 == 1) {
            self.short = String(Int(daysLeft/30)) + " Month"
        } else if (daysLeft/7 > 1) && (daysLeft.remainder(dividingBy: 7) > 4) {
            self.short = String(Int(ceil(daysLeft/7))) + " Weeks" // rounds up >4 days to 1 week
        } else if (daysLeft/7 > 1) {
            self.short = String(Int(floor(daysLeft/7))) + " Weeks"
        } else if (daysLeft/7 == 1) {
            self.short = String(Int(daysLeft/7)) + " Week"
        } else if (daysLeft > 1) {
            self.short = String(Int(daysLeft)) + " Days"
        } else if (daysLeft == 1) {
            self.short = "1 Day"
        } else {
            self.short = "Overdue"
        }
    }
 
    func createReminder() {
        
        // Configure notification text
        let content = UNMutableNotificationContent()
        content.title = "ReplaceMe"
        content.body = "It's time to replace your " + self.name
        content.sound = .default
        // Configure the recurring date.
        var dateComponent = DateComponents()
        let calendar = Calendar.current
        
        // TODO: Check For Error Here (only using dayreminder now)
        
        var remDateComponent = DateComponents()
        remDateComponent.day = -1*(self.daysReminder)
        
        let reminderDate = Calendar.current.date(byAdding: remDateComponent, to: self.nextReplaced)!
        let components = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponent.year = components.year
        dateComponent.month = components.month
        dateComponent.day = components.day
        dateComponent.hour = myHour
        dateComponent.minute = myMinute
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false) // set to true to continuously remind // would become curr notifs or wtv // would need to delete curr notifs when editing time
        // Create the request
        self.uuid = UUID().uuidString
        // TODO: Notice That New String Created Every Reminder, Does That Effect Deletion?
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        // Schedule the request with the system.
        UNUserNotificationCenter.current().add(request) { (error) in
           if error != nil {
             print("ERROR: notification was NOT created")
           }
        }
        
        
    }
    
    func getColor() -> UIColor {
        if (ratio >= 0.75) {
            return UIColor(red: 64.0/255.0, green: 168.0/255.0, blue: 95.0/255.0, alpha: 255.0/255.0)
        } else if (ratio >= 0.50) {
            return UIColor(red: 97.0/255.0, green: 189.0/255.0, blue: 109.0/255.0, alpha: 255.0/255.0)
        } else if (ratio >= 0.25) {
            return UIColor(red: 250.0/255.0, green: 197.0/255.0, blue: 27.0/255.0, alpha: 255.0/255.0)
        } else if ratio > 0 {
            return UIColor(red: 225.0/255.0, green: 73.0/255.0, blue: 57.0/255.0, alpha: 255.0/255.0)
        } else {
            return UIColor(red: 184.0/255.0, green: 49.0/255.0, blue: 47.0/255.0, alpha: 255.0/255.0)
        }
    }
    
}
