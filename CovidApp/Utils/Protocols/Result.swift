//
//  Result.swift
//  FindABox
//
//  Created by jerome on 16/09/2019.
//  Copyright © 2019 Jerome TONNELIER. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}
