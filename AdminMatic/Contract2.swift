//
//  Contract2.swift
//  AdminMatic2
//
//  Created by Nick on 6/24/19.
//  Copyright © 2019 Nick. All rights reserved.
//



import Foundation

class Contract2: Codable {
    
    
    enum CodingKeys : String, CodingKey {
        case ID
        case title
        case status
        case createdBy
        
        
        case statusName
        case chargeType
        case customerID = "customer"
        case customerName = "custName"
        case custTax
        case custTerms
        case allowImages
        
        
        case notes
        case salesRep
        case repName
        
        case createDate
        case subTotal
        case taxTotal
        case total
        case terms
        case termsDescription
        case daysAged
        
        case repSignature 
        case customerSignature = "customerSigned"
        case repSignaturePath
        case customerSignaturePath
        case lead
        
        case items
        
        
        
    }
    
    var ID: String
    var title: String
    var status: String
    var createdBy: String
    
    
    var customerID:String?
    var customerName:String?
    var custTax: String?
    var custTerms: String?
    var allowImages:String?
    
    var statusName: String?
    var chargeType: String? //1 = NC, 2 = FL, 3 = T&M
    //var customer: Customer2?
    
    var notes: String?
    var salesRep: String?
    var repName: String?
    
    
    var createDate:String?
    var subTotal: String?
    var taxTotal: String?
    var total: String?
    var terms: String?
    var termsDescription: String?
    var daysAged: String?
    
    /*
    var customerSignature:Signature2?
    var repSignature:Signature2?
    */
    
    
    var repSignature:String? = "0"
    var customerSignature:String? = "0"
    
    var repSignaturePath:String? = ""
    var customerSignaturePath:String? = ""
    
    
    var items:[ContractItem2]? = []
    
    var lead:Lead2?
    var custNameAndID:String?
    
    
    init(_ID:String, _title:String, _status: String, _createdBy:String) {
        
        self.ID = _ID
        self.title = _title
        self.status = _status
        self.createdBy = _createdBy
    }
}



