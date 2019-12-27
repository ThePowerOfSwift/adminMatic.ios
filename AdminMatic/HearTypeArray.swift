//
//  HearTypeArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation


class HearTypeArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        case hearTypes
    }
    
    var hearTypes: [HearType]
    
    
    init(_hearTypes:[HearType]) {
        self.hearTypes = _hearTypes
    }
    
}



