//
//  StringExt.swift
//  FindABox
//
//  Created by jerome on 15/09/2019.
//  Copyright © 2019 Jerome TONNELIER. All rights reserved.
//

import Foundation

extension String {
    func local() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
