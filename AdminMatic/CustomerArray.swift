//
//  CustomerArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/9/19.
//  Copyright © 2019 Nick. All rights reserved.
//


class CustomerArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case customers
        
    }
    
    var customers: [Customer2]
    
    
    
    init(_customers:[Customer2]) {
        self.customers = _customers
    }
    
}

