//
//  PayrollArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/26/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation


class PayrollArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case payroll
        
    }
    
    var payroll: [Payroll2]
    
    
    
    init(_payroll:[Payroll2]) {
        self.payroll = _payroll
    }
    
}

