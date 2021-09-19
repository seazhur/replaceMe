//
//  ViewController.swift
//  ReplaceMe
//
//  Created by Cesar Fuentes on 5/13/21.
//


// TODO: Change Text of Settings After Purchasing
// TODO: Fix Layout Problems Across Devices
// TODO: Accessibility
// TODO: Make ReplaceMe Button Unclickable (Ensure that you don't overreplace or underreplace an item.)
// TODO: Implement Badge Notification For Past Due Items





import RealmSwift
import UserNotifications
import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    // MARK: Outlets
    

    @IBOutlet var table: UITableView!
    
    
    // MARK: Properties
    
    
    private var data : Results<RepItem>!
    private let realm = try! Realm()
    
    
    // MARK: Initializers
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        
        // intialize global variables once
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            myHour = 9
            myMinute = 0
            MAX_ITEMS = 3
            notificationGranted = false
            // TODO: Set lastChecked to an impossible date 1940
            lastChecked = Calendar.current.date(byAdding: DateComponents(year: -1), to: Date())!
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        // asks user for notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { (granted, error) in
            notificationGranted = granted
            if let error = error {
                print("granted, but Error in notification permission:\(error.localizedDescription)")
            }
        }
        
        // for removing all delivered notifications
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // update data array
        data = realm.objects(RepItem.self).sorted(byKeyPath: "nextReplaced", ascending: true)
        
        // refresh items for today's date
        refreshItemsDaily()
        
        // table cell properties
        let nib = UINib(nibName: "RepItemTableViewCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: "RepItemTableViewCell")
        table.delegate = self
        table.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // refresh items for today's date
        refreshItemsDaily()
    }

 
    // MARK: TABLE
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepItemTableViewCell", for: indexPath) as! RepItemTableViewCell
        cell.cellNameLabel.text = data[indexPath.row].name
        cell.cellTimeLabel.layer.masksToBounds = true
        cell.cellTimeLabel.layer.cornerRadius = 5
        cell.cellTimeLabel.backgroundColor = data[indexPath.row].getColor()
        cell.cellTimeLabel.text = data[indexPath.row].short
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = storyboard?.instantiateViewController(identifier: "view") as? DetailViewController
        let item = data[indexPath.row]
        vc!.item = item
        vc!.replaceMeHandler = { [weak self] in self?.refresh() }
        vc!.editHander = { [weak self] in self?.edit() }
        
        
        
        
        
        
        
        present(vc!, animated: true)
    }
    

    // MARK: ACTIONS
    

    @IBAction func didTapAddButton() {
        
        // TODO: Make Sure Alert Text Changes When Adding More Than 60, Use didBuySpace Boolean Variable

        if (data.count >= MAX_ITEMS) {
            
            // TODO: Add Button To Update App
            
            // too many items
            let defaultAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in }
            let upgradeAction = UIAlertAction(title: "Upgrade", style: .default) { (action) in }
            let alert = UIAlertController(title: "Too Many Items", message: "Please delete older items or upgrade the app.", preferredStyle: .alert)
            alert.addAction(defaultAction)
            alert.addAction(upgradeAction)
            self.present(alert, animated: true) {}
            
        } else {

            let vc = storyboard?.instantiateViewController(identifier: "enter") as? AddViewController
            vc?.addCompletionHandler = { [weak self] in self?.refresh() }
            let nc = UINavigationController(rootViewController: vc!)
            self.present(nc, animated:true, completion: nil)
            
        }
    }
    
    @IBAction func didTapSettingsButton() {
        let vc = storyboard?.instantiateViewController(identifier: "settings") as? SettingsTableViewController
        vc!.data = data
        present(vc!, animated: true)
    }


    // MARK: Handlers
    

    func refresh() {
        data = realm.objects(RepItem.self).sorted(byKeyPath: "nextReplaced", ascending: true)
        table.reloadData()
    }

    func refreshItemsDaily() {
        if (!Calendar.current.isDate(Date(), equalTo: lastChecked, toGranularity: .day)) {
            for currItem in data {
                let i = self.realm.object(ofType: RepItem.self, forPrimaryKey: currItem.name)!
                try! self.realm.write {
                    i.updateRatioAbb()
                }
            }
        }
        lastChecked = Date()
    }
    
    func edit() {
        let vc = storyboard?.instantiateViewController(identifier: "enter") as? AddViewController
        vc?.addCompletionHandler = { [weak self] in self?.refresh() }
        
        vc?.item = globalItem
        let nc = UINavigationController(rootViewController: vc!)
        self.present(nc, animated:true, completion: nil)
        
    }

    
}


/*


 
 let vc = storyboard?.instantiateViewController(identifier: "enter") as? AddViewController
 vc!.addCompletionHandler = { [weak self] in self?.refresh() }
 vc!.item = globalItem
 present(vc!, animated: true)
 
 
 
 
 let vc = storyboard?.instantiateViewController(identifier: "enter") as? AddViewController
 vc!.addCompletionHandler = { [weak self] in self?.refresh() }
 vc!.item = globalItem
 present(vc!, animated: true)
 
 
 */
