//
//  Item.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
