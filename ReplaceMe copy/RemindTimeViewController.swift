//
//  RemindTimeViewController.swift
//  ReplaceMe
//
//  Created by Cesar Fuentes on 5/24/21.
//

import UIKit

class remindTimeViewController: UIViewController {


    // MARK: PROPERTIES


    @IBOutlet weak var timePicker: UIDatePicker!
    public var timeCompletionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .always
        
        // when view loads, set date picker to current date and style
        timePicker.setDate(Date(), animated: true)
        timePicker.preferredDatePickerStyle = .wheels
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapNotifSaveButton))
        
    }
    
    
    // MARK: ACTIONS
    
    
    @objc func didTapNotifSaveButton() {
        let time = timePicker.date
        let calendar = Calendar.current
        myHour = calendar.component(.hour, from: time)
        myMinute = calendar.component(.minute, from: time) 
        timeCompletionHandler?()        
        // dismiss controller
        self.navigationController?.popViewController(animated: true)
    }

}
