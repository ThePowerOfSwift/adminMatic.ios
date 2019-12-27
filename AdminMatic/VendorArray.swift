//
//  VendorArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/9/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation


class VendorArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case vendors
        
    }
    
    var vendors: [Vendor2]
    
    
    
    init(_vendors:[Vendor2]) {
        self.vendors = _vendors
    }
    
}


