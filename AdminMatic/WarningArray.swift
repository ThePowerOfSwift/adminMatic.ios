//
//  WarningArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/12/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

class WarningArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case warningArray
        
    }
    
    var warningArray: [String]
    
    
    
    init(_warningArray:[String]) {
        self.warningArray = _warningArray
    }
    
}

