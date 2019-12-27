//
//  Customer2.swift
//  AdminMatic2
//
//  Created by Nick on 6/5/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class Customer2: Codable {
    var ID: String
    var sysname:String
    
    
    //optional vars
    var address: String?
    var balance:String?
    var hear:String?
    var active:String?
    var fname:String?
    var mname:String?
    var lname:String?
    var companyName:String?
    var salutation:String?
    var custNotes:String?
    var servNotes:String?
    var allowImages:String?
    
    var contacts:[Contact2]?

    
    enum CodingKeys : String, CodingKey {
        case ID
        case sysname
        
        case address = "mainAddr"
        case balance
        case hear
        case active
        case fname
        case mname
        case lname
        case companyName
        case salutation
        case custNotes
        case servNotes
        case allowImages
        case contacts
    }
    
    init(_ID:String, _sysname: String){
        self.ID = _ID
        self.sysname = _sysname
    }
    
    
   
    
    
}


