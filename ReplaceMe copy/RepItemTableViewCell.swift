//
//  RepItemTableViewCell.swift
//  ReplaceMe
//
//  Created by Cesar Fuentes on 5/14/21.
//

import UIKit

class RepItemTableViewCell: UITableViewCell {

    @IBOutlet var cellNameLabel: UILabel!
    @IBOutlet var cellTimeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
