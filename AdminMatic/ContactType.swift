//
//  ContactType.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

class ContactType: Codable {
    
    enum CodingKeys : String, CodingKey {
        case ID
        case name
    }
    
    var ID: String
    var name: String
    
    init(_ID:String, _name: String) {
        self.ID = _ID
        self.name = _name
    }
}


