//
//  InvoiceItem2.swift
//  AdminMatic2
//
//  Created by Nick on 6/24/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation


class InvoiceItem2: Codable {
    
    
    enum CodingKeys : String, CodingKey {
        
        case ID
        case name = "item"
        case chargeType = "charge"
        case qty = "act"
        case invoiceID
        case price
        case servicedDate
        case itemID
        case totalImages
        case total
        case type
        case taxCode
        case hideUnits
        case custDescription = "custDesc"
        
            
        
    }
    
    
    var ID: String
    var name: String
    var chargeType: String
    var qty: String
    var invoiceID: String
    var price: String
    var servicedDate: String
    var itemID: String
    
    var total: String
    var type: String
    
    
    var hideUnits: String
    
    var custDescription: String
    
    var totalImages: String?
    var taxCode: String?
    
    //var invoiceTitle:String
    
    init(_ID: String,_chargeType: String,_invoiceID: String,_servicedDate: String,_itemID: String,_name: String,_price: String,_qty: String,_total: String,_type: String,_hideUnits: String,_custDescription: String) {
        //print(json)
        
            self.ID = _ID
        
            self.chargeType = _chargeType
        
            self.invoiceID = _invoiceID
        
            self.servicedDate = _servicedDate
        
            self.itemID = _itemID
        
            self.name = _name
        
            self.price = _price
        
            self.qty = _qty
        
            //self.totalImages = _totalImages
        
            self.total = _total
        
            self.type = _type
        
            //self.taxCode = _taxCode
        
            self.hideUnits = _hideUnits
        
            self.custDescription = _custDescription
        
    }
    
    
}
