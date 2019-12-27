//
//  HearTypes.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

class HearType: Codable {
    
    enum CodingKeys : String, CodingKey {
        case ID
        case type
    }
    
    var ID: String
    var type: String
    
    init(_ID:String, _type: String) {
        self.ID = _ID
        self.type = _type
    }
}


