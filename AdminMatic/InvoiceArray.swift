//
//  InvoiceArray.swift
//  AdminMatic2
//
//  Created by Nick on 6/24/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation





class InvoiceArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case invoices
       
    }
    
    var invoices: [Invoice2]
    
    
    
    init(_invoices:[Invoice2]) {
        self.invoices = _invoices
    }
    
}

