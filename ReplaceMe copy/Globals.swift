//
//  Globals.swift
//  ReplaceMe
//
//  Created by Cesar Fuentes on 6/9/21.
//


import Foundation


//MARK: STATE


var myHour: Int {
    get { return UserDefaults.standard.integer(forKey: "myHour") }
    set { UserDefaults.standard.set(newValue, forKey: "myHour") }
}

var myMinute: Int {
    get { return UserDefaults.standard.integer(forKey: "myMinute") }
    set { UserDefaults.standard.set(newValue, forKey: "myMinute") }
}

var MAX_ITEMS: Int {
    get { return UserDefaults.standard.integer(forKey: "MAX_ITEMS") }
    set { UserDefaults.standard.set(newValue, forKey: "MAX_ITEMS") }
}

var notificationGranted: Bool {
    get { return UserDefaults.standard.bool(forKey: "notificationGranted") }
    set { UserDefaults.standard.set(newValue, forKey: "notificationGranted") }
}

var lastChecked: Date {
    get { return UserDefaults.standard.object(forKey: "lastChecked") as! Date }
    set { UserDefaults.standard.set(newValue, forKey: "lastChecked") }
}


//MARK: NON-STATE


var globalItem: RepItem = RepItem()
var didEditItem: Bool = false

