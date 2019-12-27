
//
//  LeadArray.swift
//  AdminMatic2
//
//  Created by Nick on 6/27/19.
//  Copyright © 2019 Nick. All rights reserved.
//

class DepartmentArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case departments
        
    }
    
    var departments: [Department2]
    
    
    
    init(_departments:[Department2]) {
        self.departments = _departments
    }
    
}

