//
//  AddViewController.swift
//  ReplaceMe
//
//  Created by Cesar Fuentes on 5/13/21.
//


import RealmSwift
import UIKit


class AddViewController: UITableViewController, UITextFieldDelegate {


    // MARK: Outlets


    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var calendar: UIDatePicker!
    @IBOutlet weak var replacePicker: UIPickerView!
    @IBOutlet weak var remindPicker: UIPickerView!
    @IBOutlet weak var suggestionsPicker: UIPickerView!
    

    @IBOutlet weak var calendarIcon: UIView!
    @IBOutlet weak var repeatIcon: UIView!
    @IBOutlet weak var alarmIcon: UIView!
    @IBOutlet weak var bulbIcon: UIView!
    
    
    
    @IBOutlet weak var addTableView: UITableView!
    
    
    // MARK: Properties
    
    
    public var item: RepItem? // if editing an item
    private let realm = try! Realm()
    public var addCompletionHandler: (() -> Void)?

    var months = Array(0...100)
    var weeks = Array(0...4)
    var days = Array(0...31)
    
    var reminders = ["The Day Of", "1 Day Before", "2 Days Before", "1 Week Before", "2 Weeks Before"]
    var remindersTime = [0,1,2,7,14]
    
    var suggestions = ["", "Sponge", "Tire Pressure", "Toothbrush", "Air Filter", "Contact Lens Case", "Tire Rotation", "Engine Oil", "Smoke Alarm Batteries", "Water Filter"]
    var suggestedTime = ["": ("Day",0), "Sponge": ("Week",3), "Tire Pressure": ("Month",1), "Toothbrush": ("Month",3), "Air Filter": ("Month",3), "Contact Lens Case": ("Month",3), "Tire Rotation": ("Month",6), "Engine Oil": ("Month",6), "Smoke Alarm Batteries": ("Month",6), "Water Filter": ("Month",6)]
    
    
    // MARK: Initializer
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTableView.delegate = self
        // self.title = course?.courseName
        
        
        textField.delegate = self
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.systemGray6
        
        // remove line between navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        
        
        
        calendarIcon.layer.masksToBounds = true
        calendarIcon.layer.cornerRadius = 5
        repeatIcon.layer.masksToBounds = true
        repeatIcon.layer.cornerRadius = 5
        alarmIcon.layer.masksToBounds = true
        alarmIcon.layer.cornerRadius = 5
        bulbIcon.layer.masksToBounds = true
        bulbIcon.layer.cornerRadius = 5


        
        replacePicker.delegate = self
        replacePicker.dataSource = self
        replacePicker.tag = 1
        
        remindPicker.delegate = self
        remindPicker.dataSource = self
        remindPicker.tag = 2

        suggestionsPicker.delegate = self
        suggestionsPicker.dataSource = self
        suggestionsPicker.tag = 3
        
        if (didEditItem) {
            fillContents(item: item!)
         
            
            // Change Title To Edit
            // Change Button Names To Delete/Save
            
         
            didEditItem = false
        } else {
            
            calendar.setDate(Date(), animated: true)
            
            replacePicker.selectRow(0, inComponent: 0, animated: true)
            replacePicker.selectRow(0, inComponent: 1, animated: true)
            replacePicker.selectRow(0, inComponent: 2, animated: true)

            remindPicker.selectRow(0, inComponent: 0, animated: true)
            
            // set suggestionsPicker?
            
        }
 
    }
    
    
    // MARK: ACTIONS
    
    
    @IBAction func didTapDelete(_ sender: Any) {
        
        // TODO: See If Lowering Tab Will Also Delete
        
        let defaultAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.addCompletionHandler?() // is this necessary?
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        let alert = UIAlertController(title: "Are you sure?",
            message: "Your item will be lost.",
            preferredStyle: .alert)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true) {
        }
        
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        
        let text = textField.text
        let month = Int(replacePicker.selectedRow(inComponent: 0))
        let week = Int(replacePicker.selectedRow(inComponent: 1))
        let day = Int(replacePicker.selectedRow(inComponent: 2))
        let dayReminder = remindersTime[remindPicker.selectedRow(inComponent: 0)]
        let m = (month == 0)
        let w = (week == 0)
        let d = (day == 0)

        if (text!.isEmpty) {
            
            // CASE: missing name
            let defaultAction = UIAlertAction(title: "Okay", style: .default) { (action) in }
            let alert = UIAlertController(title: "Missing Item", message: "Please name your item.", preferredStyle: .alert)
            alert.addAction(defaultAction)
            self.present(alert, animated: true) {}
        
        } else if (m && w && d) {
            
            // CASE: no input time
            let defaultAction = UIAlertAction(title: "Okay", style: .default) { (action) in }
            let alert = UIAlertController(title: "Missing Time", message: "Please add how often this item should be replaced.", preferredStyle: .alert)
            alert.addAction(defaultAction)
            self.present(alert, animated: true) {}
        
        } else if (realm.object(ofType: RepItem.self, forPrimaryKey: text) != nil) {
            
            // CASE: duplicate item
            let defaultAction = UIAlertAction(title: "Okay", style: .default) { (action) in }
            let alert = UIAlertController(title: "Duplicate Item", message: "At item with that name already exists. Please choose a different name", preferredStyle: .alert)
            alert.addAction(defaultAction)
            self.present(alert, animated: true) {}
            
        } else if ((month*31)+(week*7)+(day) <= dayReminder) {
            
            // CASE: reminder >= replace time interval
            let defaultAction = UIAlertAction(title: "Okay", style: .default) { (action) in }
            let alert = UIAlertController(title: "Incorrect Reminder Time", message: "Your reminder time interval is too big. Please choose a different reminder time", preferredStyle: .alert)
            alert.addAction(defaultAction)
            self.present(alert, animated: true) {}
            
        } else {
            
            // CASE: meets all requirements
            let date = calendar.date
            realm.beginWrite()
            guard let newItem = RepItem(name: text!, date: date, months: month, weeks: week, days: day, daysReminder: dayReminder) else { return }
            realm.add(newItem)
            try! realm.commitWrite()
            addCompletionHandler?()
            dismiss(animated: true, completion: nil)
            
        }
        
        print("Saved")
        
    }
    

    func fillContents(item: RepItem) {
        
        // name/title
        self.textField.text = item.name
        
        // last replaced
        self.calendar.setDate(item.lastReplaced, animated: false)
        
        // replace this often
        self.replacePicker.selectRow(item.months, inComponent: 0, animated: true)
        self.replacePicker.selectRow(item.weeks, inComponent: 1, animated: true)
        self.replacePicker.selectRow(item.days, inComponent: 2, animated: true)
        
        // remind before
        self.remindPicker.selectRow(remindersTime.firstIndex(of: item.daysReminder)!, inComponent: 0, animated: true)
        
        realm.beginWrite()
        realm.delete(item)
        try! realm.commitWrite()
        
    }
    
    
    // MARK: TABLE
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // change
        
        if indexPath.row == 1 {
            if indexPath.section == 1 {
                return 100
            } else if indexPath.section == 2 {
                return 100
            }
            return 70
        }
        
        
        return tableView.rowHeight
        
    }
    

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 0
        }
        return 18
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    
    
    /*
     override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         return .leastNormalMagnitude
     }
     */
    
    
    
    // MARK: TextField
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}


// MARK: SUGGESTIONS PICKER


extension AddViewController: UIPickerViewDataSource {
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1 {
            return 3
        } else if pickerView.tag == 2 {
            return 1
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 {
            if component == 0 {
                return months.count
            } else if component == 1 {
                return weeks.count
            } else {
                return days.count
            }
        } else if pickerView.tag == 2 {
            return reminders.count
        } else {
            return suggestions.count
        }
        
    }
    
}

extension AddViewController: UIPickerViewDelegate {
 
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            if component == 0 {
                return String(months[row])
            } else if component == 1 {
                return String(weeks[row])
            } else {
                return String(days[row])
            }
        } else if pickerView.tag == 2 {
            return reminders[row]
        } else {
            return suggestions[row]
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // suggestions picker
        if pickerView.tag == 3 {
            
            textField.text = suggestions[row]
            
            let str = suggestedTime[suggestions[row]]?.0
            let num = suggestedTime[suggestions[row]]?.1
            
            if (str == "Month") {
                replacePicker.selectRow(num!, inComponent: 0, animated: true)
                replacePicker.selectRow(0, inComponent: 1, animated: true)
                replacePicker.selectRow(0, inComponent: 2, animated: true)
            } else if (str == "Week") {
                replacePicker.selectRow(0, inComponent: 0, animated: true)
                replacePicker.selectRow(num!, inComponent: 1, animated: true)
                replacePicker.selectRow(0, inComponent: 2, animated: true)
            } else if (str == "Day") {
                replacePicker.selectRow(0, inComponent: 0, animated: true)
                replacePicker.selectRow(0, inComponent: 1, animated: true)
                replacePicker.selectRow(num!, inComponent: 2, animated: true)
            }
            
        }
    }
}







/*

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = suggestions[row]
        
 
 
        let str = suggestedTime[suggestions[row]]?.0
        let num = suggestedTime[suggestions[row]]?.1
        
        if (str == "Month") {
            monthStepper.numberLabel.text = String(num!)
            weekStepper.numberLabel.text = "0"
            dayStepper.numberLabel.text = "0"
        } else if (str == "Week") {
            monthStepper.numberLabel.text = "0"
            weekStepper.numberLabel.text = String(num!)
            dayStepper.numberLabel.text = "0"
        } else if (str == "Day") {
            monthStepper.numberLabel.text = "0"
            weekStepper.numberLabel.text = "0"
            dayStepper.numberLabel.text = String(num!)
        }
    }

 
 
 
 
 var suggestions = ["Sponge", "Tire Pressure", "Toothbrush", "Air Filter", "Contact Lens Case", "Tire Rotation", "Engine Oil", "Smoke Alarm Batteries", "Water Filter"]
 var suggestedTime = ["Sponge": ("Week",3), "Tire Pressure": ("Month",1), "Toothbrush": ("Month",3), "Air Filter": ("Month",3), "Contact Lens Case": ("Month",3), "Tire Rotation": ("Month",6), "Engine Oil": ("Month",6), "Smoke Alarm Batteries": ("Month",6), "Water Filter": ("Month",6)]
 
 
*/
