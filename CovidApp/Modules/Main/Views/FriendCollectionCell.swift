//
//  FriendCollectionCell.swift
//  CovidApp
//
//  Created by jerome on 08/04/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

enum FriendCellType {
    case add
    case friend(_: User)
}
 
class FriendCollectionCell: UICollectionViewCell {

    @IBOutlet weak var card: UIView!  {
        didSet {
            card.setAsDefaultCard()
        }
    }

    @IBOutlet weak var iconBackground: UIView!  {
        didSet {
            iconBackground.roundedCorners = true
        }
    }

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with type: FriendCellType) {
        switch type {
        case .add:
            card.backgroundColor = Palette.basic.primary.color
            iconBackground.backgroundColor = .white
            icon.tintColor = Palette.basic.primary.color
            icon.image = UIImage(named: "add")
            name.text = "add a friend".local()
            name.textColor = .white
            
        case .friend(let friend):
            card.backgroundColor = friend.state.color.withAlphaComponent(0.5)
            iconBackground.backgroundColor = .white
            icon.image = friend.state.icon
            name.text = friend.userName
            name.textColor = .white
        }
    }
}

private enum UserState {
    case fine
    case ill
    
    var color: UIColor {
        switch self {
        case .fine: return Palette.basic.confirmation.color
        case .ill: return Palette.basic.alert.color
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .fine: return UIImage(named: "shareFaces")
        case .ill: return UIImage(named: "drippingNose")
        }
    }
}

private extension User {
    var state: UserState {
        let states = metrics[0..<min(3, metrics.count)].reduce(0) { (result, metric) -> Int in
            return result + metric.metrics.compactMap({ $0.value == true ? 0 : 1 }).reduce(0, { (res, intValue) -> Int in
                return intValue
            })
        }
        return states > 0 ? .ill : .fine
    }
}
