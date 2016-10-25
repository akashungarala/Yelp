//
//  SwitchCell.swift
//  Yelp
//
//  Created by Akash Ungarala on 10/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {
    
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    @IBOutlet weak var choiceLabel: UILabel!
    @IBOutlet weak var choiceImageView: UIImageView!
    @IBOutlet weak var seeAllLabel: UILabel!

    weak var delegate: SwitchCellDelegate?

    var onChecked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func switchValueChanged(sender: AnyObject) {
        delegate?.switchCell?(switchCell: self, didChangeValue: onSwitch.isOn)
    }

}
