//
//  NotificationSettingsCell.swift
//  CovidApp
//
//  Created by jerome on 07/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class NotificationSettingsCell: UITableViewCell {

    weak var delegate: DailyNotificationDelegate? = nil
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        datePicker.isHidden = true
        updateHourLabel()
    }
    
    private func updateHourLabel() {
        guard let date = Defaults[\.hourForNotification] else { return }
        hourLabel.set(text: String(format: "reminder time".local(), DateFormatter.timeOnlyFormatter.string(from: date)), for: .default)
    }
    
    var expand: Bool = false  {
        didSet {
            datePicker.isHidden = expand == false
            updateHourLabel()
        }
    }
    
    @IBAction func timeChange(_ sender: UIDatePicker) {
        delegate?.updateDailyNotification(for: sender.date)
        updateHourLabel()
    }
}
