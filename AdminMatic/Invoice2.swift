//
//  Invoice2.swift
//  AdminMatic2
//
//  Created by Nick on 6/24/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation



/*
 Status
 0 = syncing to QB
 1 = pending
 2 = final
 3 = sent (printed/emailed)
 4 = paid
 5 = void
 */


class Invoice2: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case ID
        case date = "invoiceDate"
        case totalPrice = "total"
        case status = "invoiceStatus"
        //case customer
        
        case customerID = "customer"
        case customerName = "custName"
        case title
        case chargeType = "charge"
        case repName = "salesRepName"
        case notes
        case subTotal
        case taxTotal
        case lead
        case contract
        
        case items
    }
    
    var ID: String
    var date: String
    var totalPrice:String
    var status:String
    
    var customerID:String
    var customerName:String
    
    //Optional Vars
   // var customer:Customer2?
    var title:String?
    var chargeType:String?
    var repName:String?
    var notes:String?
    var subTotal:String?
    var taxTotal:String?
    var items:[InvoiceItem2]?
    var lead:Lead2?
    var contract:Contract2?
    
    
    init(_ID:String, _date:String, _totalPrice:String, _status:String, _customerID:String, _customerName:String) {
        self.ID = _ID
        self.date = _date
        self.totalPrice = _totalPrice
        self.status = _status
        self.customerID = _customerID
        self.customerName = _customerName
        
        //self.customer = Customer2(_ID: _customerID, _sysname: _customerName)
    }

}

