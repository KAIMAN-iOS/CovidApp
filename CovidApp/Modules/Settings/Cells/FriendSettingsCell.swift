//
//  FriendSettingsCell.swift
//  CovidApp
//
//  Created by jerome on 07/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class FriendSettingsCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with friend: Friend) {
        icon.image = friend.icon
        name.set(text: friend.userName, for: .default)
    }

    @IBAction func deleteFriend(_ sender: Any) {
    }
}
