//
//  ZoneArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation


class ZoneArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        case zones
    }
    
    var zones: [Zone2]
    
    
    init(_zones:[Zone2]) {
        self.zones = _zones
    }
    
}




