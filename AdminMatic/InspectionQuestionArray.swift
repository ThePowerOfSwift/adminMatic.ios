//
//  InspectionQuestionArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation


class InspectionQuestionArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        case inspectionQuestions
    }
    
    var inspectionQuestions: [InspectionQuestion2]
    
    
    init(_inspectionQuestions:[InspectionQuestion2]) {
        self.inspectionQuestions = _inspectionQuestions
    }
    
}



