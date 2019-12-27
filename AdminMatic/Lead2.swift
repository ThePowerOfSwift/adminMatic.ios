//
//  Lead2.swift
//  AdminMatic2
//
//  Created by Nick on 6/21/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation



class Lead2: Codable {
    
    
    enum CodingKeys : String, CodingKey {
        case ID
        case statusID
        case scheduleType = "timeType"
        case createdBy
        case statusName
       // case customer
        
        case customerID = "customer"
        case customerName = "custName"
        case allowImages
        case custTax
        case custTerms
        
        case zone
        case address
        case date
        case dateNice
        case time
        case rep = "salesRep"
        case repName
        case requestedByCust
        case urgent
        case description
        case deadline = "deadlineNice"
        case daysAged
        case tasksArray = "tasks"
    }
    
    var ID: String
    var statusID: String
    var scheduleType: String //0 = ASAP, 1 = FIRM
    var createdBy: String
    
    //optional vars
    var statusName: String?
   // var customer:Customer2?
    
    var customerID:String?
    var customerName:String?
    var allowImages:String?
    var custTax: String?
    var custTerms: String?
    
    
   // var zone:Zone2?
    var zone:String?
    var address:String?
    var date: String?// send as YYYY-MM-DD
    var dateNice:String?
    var time: String?// send as HH:MM 24 hr time
    var rep: String?
    var repName: String?
    var requestedByCust: String?
    var urgent: String?
    var description: String?
    var deadline: String?
    var daysAged: String?
    var tasksArray:[Task2]? = []
    var custNameAndID:String?
    var custNameAndZone:String?
    
    
    init(_ID:String, _statusID: String,_scheduleType:String, _createdBy:String) {
        self.ID = _ID
        self.statusID = _statusID
        self.scheduleType = _scheduleType
        self.createdBy = _createdBy
    }
    
}

