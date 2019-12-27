//
//  Zone2.swift
//  AdminMatic2
//
//  Created by Nick on 6/24/19.
//  Copyright © 2019 Nick. All rights reserved.
//




import Foundation

class Zone2: Codable {
    
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

