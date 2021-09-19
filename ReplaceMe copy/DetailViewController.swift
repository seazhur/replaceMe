//
//  DetailViewController.swift
//  ReplaceMe
//
//  Created by Cesar Fuentes on 5/13/21.
//


import RealmSwift
import UIKit


class DetailViewController: UITableViewController, UITextFieldDelegate {
    
    
    // MARK: Outlets
    
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var prevDateLabel: UILabel!
    @IBOutlet weak var nextDateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var replaceMeButton: UIButton!
    // cirular uiviews/icons
    
    
    @IBOutlet weak var calendarIcon: UIView!
    @IBOutlet weak var calendar2Icon: UIView!
    @IBOutlet weak var repeatIcon: UIView!
    @IBOutlet weak var bellIcon: UIView!
    
    
    
    // MARK: Properties
    
    
    public var item: RepItem?
    private let realm = try! Realm()
    public var replaceMeHandler: (() -> Void)?
    public var editHander: (() -> Void)?
    
    
    // MARK: Initializer
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        calendarIcon.layer.masksToBounds = true
        calendarIcon.layer.cornerRadius = 5
        calendar2Icon.layer.masksToBounds = true
        calendar2Icon.layer.cornerRadius = 5
        repeatIcon.layer.masksToBounds = true
        repeatIcon.layer.cornerRadius = 5
        bellIcon.layer.masksToBounds = true
        bellIcon.layer.cornerRadius = 5


        
        //         addTableView.delegate = self
        
        
        /*
        let m = item!.months == 0 ? "" : String(item!.months) + " months "
        let w = item!.weeks == 0 ? "" : String(item!.weeks) + " weeks "
        let d = item!.days == 0 ? "" : String(item!.days) + " days "
        */
        
        // intervalLabel.text = m + w + d
        
        
        
        
        monthLabel.text = String(item!.months)
        weekLabel.text = String(item!.weeks)
        dayLabel.text = String(item!.days)
        
        
        
        
        
        
        nextDateLabel.text = Self.dateFormatter.string(from: item!.nextReplaced)
        prevDateLabel.text = Self.dateFormatter.string(from: item!.lastReplaced)
        itemNameLabel.text = item?.name
        
        
        
        
        
        // change battery color + percentage (size)
        // self.battery.configureView(item: item!)
        
        
        
        
        
    }
    

    // MARK: ACTIONS
    
    
    @IBAction func didTapEdit(_ sender: Any) {
        
        // adjust global variables
        globalItem = item!
        didEditItem = true
        
        dismiss(animated: true, completion: nil)
        self.editHander?()
        
    }
    
    @IBAction func didTapReplaceMe() {
        
        let cancelAction = UIAlertAction(title: "Not Yet", style: .cancel) { (action) in }
        let defaultAction = UIAlertAction(title: "Yes!", style: .default) { (action) in
        let i = self.realm.object(ofType: RepItem.self, forPrimaryKey: self.item?.name)!
            try! self.realm.write {
                i.lastReplaced = Date()
                i.updateNextReplaced()
                i.updateRatioAbb()
                i.createReminder()
            }
            self.nextDateLabel.text = Self.dateFormatter.string(from: i.nextReplaced)
            self.prevDateLabel.text = Self.dateFormatter.string(from: i.lastReplaced)
            self.replaceMeHandler?()
            
            
            
            // self.battery.configureView(item: self.item!) // ratio: self.item!.ratio
            
            
            
            
         }
         let alert = UIAlertController(title: "ReplaceMe", message: "Ready To Replace This Item?", preferredStyle: .alert)
         alert.addAction(defaultAction)
         alert.addAction(cancelAction)
         self.present(alert, animated: true) {}
        
    }
        
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter() // expensive
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    
    // MARK: TABLE
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
        if indexPath.section == 3 && indexPath.row == 1 {
            return 70
        }

        return tableView.rowHeight
        
    }
    
    
}
