//
//  EmployeeArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 11/24/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class EmployeeArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case employees
       
        
    }
    
    var employees: [Employee2]
    
    
    
    init(_employees:[Employee2]) {
        self.employees = _employees
    }
    
}



