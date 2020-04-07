//
//  HeaderView.swift
//  Moovizy
//
//  Created by jerome on 16/07/2018.
//  Copyright © 2018 CITYWAY. All rights reserved.
//

import UIKit
import SnapKit

class HeaderView: UIView {
    @IBOutlet weak var label: UILabel!
    private var textColor: UIColor = Palette.basic.mainTexts.color
    private var textFont: FontType = .title
    
    static private func createHeader() -> HeaderView {
        let view: HeaderView = HeaderView.loadFromNib()
        view.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        view.backgroundColor = Palette.basic.lightGray.color
        view.label.backgroundColor = .clear
        view.label.numberOfLines = 2
        return view
    }
    
    static func create(with text: String,
                       font: FontType = FontType.title,
                       textColor: UIColor = Palette.basic.mainTexts.color) -> HeaderView {
        let viewData = createHeader()
        viewData.textColor = textColor
        viewData.textFont = font
        viewData.label.set(text: text, for: viewData.textFont, textColor: viewData.textColor)
        viewData.layoutIfNeeded()
        return viewData
    }
    
    static func create(with attributedText: NSAttributedString) -> HeaderView {
        let viewData = createHeader()
        viewData.updateLabel(with: attributedText) {}
        viewData.layoutIfNeeded()
        return viewData
    }
    
    func updateLabel(with text: String, completion: @escaping (() -> Void)) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.label.set(text: text, for: self.textFont, textColor: self.textColor)
            self.layoutIfNeeded()
            completion()
        }
    }
    
    func updateLabel(with attributedtText: NSAttributedString, completion: @escaping (() -> Void)) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.label.attributedText = attributedtText
            self.layoutIfNeeded()
            completion()
        }
    }
}
