//
//  ErrorArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/12/19.
//  Copyright © 2019 Nick. All rights reserved.
//



import Foundation

class ErrorArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case errorArray
        
    }
    
    var errorArray: [String]
    
    
    
    init(_errorArray:[String]) {
        self.errorArray = _errorArray
    }
    
}



