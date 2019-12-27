//
//  ShiftsArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/26/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation


class ShiftsArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case shifts
        
    }
    
    var shifts: [Shift2]
    
    
    
    init(_shifts:[Shift2]) {
        self.shifts = _shifts
    }
    
}

