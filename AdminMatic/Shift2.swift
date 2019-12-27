//
//  Shift2.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

class Shift2:Codable {
    
    enum CodingKeys: String, CodingKey{
        case ID
        case empID
        case startTime
        case stopTime
        case status
        case comment
        case qty
       }
    
    var ID: String
    var empID: String
    
    var startTime: Date?
    var stopTime: Date?
    var status: String?
    var comment: String?
    var qty: String?
     
     init(_ID:String, _empID: String) {
        self.ID = _ID
        self.empID = _empID
    }
    
}



