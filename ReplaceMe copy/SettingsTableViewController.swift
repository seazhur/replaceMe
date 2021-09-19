//
//  SettingsTableViewController.swift
//  ReplaceMe
//
//  Created by Cesar Fuentes on 5/18/21.
//


import UIKit
import RealmSwift
import UserNotifications


class SettingsTableViewController: UITableViewController {


    
    
    
    
    
    
    
    
    
    
    // MARK: Outlets


    @IBOutlet var settings: UITableView! // not used!!!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var notifSwitch: UISwitch!
    
    
    // MARK: Properties
    
    
    private let realm = try! Realm()
    public var data : Results<RepItem>? // switch to public

    
    // MARK: Initializers
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // settings.delegate = self
        // settings.dataSource = self

        notifSwitch.isOn = notificationGranted
        updateReminderTimeString()

    }


    // MARK: Actions


    @IBAction func didTouchNotifSwitch(_ sender: UISwitch) {
        
	// TODO: Remove If-Statement, Combine Into One

        if (sender.isOn) {
            // try switching to on
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.notifSwitch.isOn = false
            }
            let defaultAction = UIAlertAction(title: "Settings", style: .default) { (action) in
                self.notifSwitch.isOn = false
                
                // TODO: Take To Settings
                
            }
            let alert = UIAlertController(title: "Notifications are disabled.",
                  message: "Go to the Settings app to reenable. Then close out and relaunch the app.",
                  preferredStyle: .alert)
            alert.addAction(defaultAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true) {}
        } else {
            // try switching to off
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.notifSwitch.isOn = true
            }
            let defaultAction = UIAlertAction(title: "Settings", style: .default) { (action) in
                self.notifSwitch.isOn = true
                
                // TODO: Take To Settings
                
            }
            let alert = UIAlertController(title: "Notifications are enabled.",
                  message: "Go to the Settings app to disable. Then close out and relaunch the app.",
                  preferredStyle: .alert)
            alert.addAction(defaultAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true) {}
        }
    }
    

    // MARK: TABLE


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 && !notificationGranted {
            return 0
        }
        return tableView.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0 && indexPath.row == 1 ) {
            // selecting time adjuster
            guard let vc = storyboard?.instantiateViewController(identifier: "remindTimeView") as? remindTimeViewController else {
                return
            }
            vc.timeCompletionHandler = { [weak self] in self?.refreshSettings() }
            // TODO: Check If Redundant
	    vc.title = "When To Replace"
	    // TODO: Check If Redundant
            vc.navigationItem.largeTitleDisplayMode = .always
            navigationController?.pushViewController(vc, animated: true)
        } else if (indexPath.section == 1 && indexPath.row == 0 ) {
            // Purchase
            
            // TODO: selecting purchase
            
        }  else if (indexPath.section == 1 && indexPath.row == 1 ) {
            // Rate & Review
            
            // TODO: Replace the XXXXXXXXXX below with the App Store ID for your app
            //       You can find the App Store ID in your app's product URL
            
            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/idUR545J8GKZ?action=write-review")
                else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        
        }
    }
    
    
    // MARK: Helper
    
    func updateReminderTimeString() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        let date12 = dateFormatter.date(from: String(myHour) + ":" + String(myMinute))!
        dateFormatter.dateFormat = "h:mm a"
        let date22 = dateFormatter.string(from: date12)
        timeLabel.text = "Remind at " + date22
    }
    
    func refreshSettings() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for currItem in data! {
            let i = self.realm.object(ofType: RepItem.self, forPrimaryKey: currItem.name)!
            try! self.realm.write {
                i.createReminder()
            }
        }
        updateReminderTimeString()
    }
    

}
