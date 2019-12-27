//
//  EquipmentService2.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//


 
import Foundation

class EquipmentService2:Codable{
    
    var ID: String
    var name: String //Oil Change, Coolant Flush, Etc.
    var type: String //Repeat or One Time
    var typeName: String
    var createdBy: String
    var status: String
    var equipmentID: String
    
    var frequency: String?
    var instruction: String?
    var creationDate: String?
    
    var completionDate: String?
    var completionMileage: String?
    var completedBy: String?
    var notes: String?
    
    
    
    var currentValue: String? //Current Mileage or Engine Hours
    var nextValue: String? //Mileage or Engine Hours for Next Service
    
    var serviceDue:Bool = false
    
    enum CodingKeys : String, CodingKey{
        case ID
        case name
        case type
        case typeName
        case createdBy
        case status
        case equipmentID
        
        case frequency
        case instruction
        case creationDate
        
        case completionDate
        case completionMileage
        case completedBy
        case notes
        
        case currentValue
        case nextValue
        case serviceDue
        
        
    }
    
    
    init(_ID:String, _name: String,_type:String,_typeName:String,   _createdBy:String,  _status:String,  _equipmentID:String) {
            self.ID = _ID
            self.name = _name
            self.type = _type
            self.typeName = _typeName
            self.createdBy = _createdBy
            self.status = _status
            self.equipmentID = _equipmentID
    }
}



