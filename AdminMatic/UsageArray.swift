//
//  UsageArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/9/19.
//  Copyright © 2019 Nick. All rights reserved.
//



import Foundation


class UsageArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case usages
        case usageTotalHrs
        case usageTotalPrice
        
    }
    
    var usages: [Usage2]
    var usageTotalHrs:String?
    var usageTotalPrice:String?
    
    
    
    init(_usages:[Usage2]) {
        self.usages = _usages
    }
    
}


