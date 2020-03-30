//
//  MainViewModel.swift
//  CovidApp
//
//  Created by jerome on 30/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import Foundation

enum CollectionViewType {
    case metrics, friends
}

class MainViewModel {
    func numberOfItems(in section: Int, for type: CollectionViewType) -> Int {
        return 0
    }
}
