//
//  WoItem2.swift
//  AdminMatic2
//
//  Created by Nick on 6/6/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class WoItem2: Codable {
    
    
    
    enum CodingKeys : String, CodingKey {
        case ID
        case item
        case type
        case sort
        case status
        case charge
        case total
        
        case est
        case empDesc
        case chargeName
        case act
        case price
        case totalCost
        case usageQty
        case extraUsage
        case unit = "unitName"
        case woID
        case woTitle
        case contractID
        case contractTitle
        case tax
        
        case tasks
        case usages = "usage"
        case vendors
        
        
    }
    
    var ID: String
    var item: String
    var type: String
    var sort: String
    var status: String
    var charge: String
    var total: String
    
    //optional vars
    var est: String?
    var empDesc: String?
    
    
    var chargeName: String?
    var act: String?
    var price: String?
    
    var totalCost: String?
    var usageQty: String?
    var extraUsage: String?
    var unit: String?
    var woID: String?
    var woTitle: String?
    var contractID: String?
    var contractTitle: String?
    var tax:String?
    
    var tasks: [Task2]? = []
    var usages: [Usage2]? = []
    var vendors: [Vendor2]? = []
    
    
    init(_ID:String,_name:String,_type:String,_sort:String,_status:String,_charge:String,_total:String){
        self.ID = _ID
        self.item = _name
        self.type = _type
        self.sort = _sort
        self.status = _status
        self.charge = _charge
        self.total = _total
    }
    /*
    required init(_ID: String?,_type: String?,_sort: String?,_name: String?,_est: String?,_empDesc: String?,_itemStatus: String?,_chargeID: String?,_act: String?,_price: String?,_total: String?,_totalCost: String?,_usageQty: String?,_extraUsage: String?,_unit: String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        if _sort != nil {
            self.sort = _sort
        }else{
            self.sort = ""
        }
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        if _est != nil {
            self.est = _est
        }else{
            self.est = ""
        }
        if _empDesc != nil {
            self.empDesc = _empDesc
        }else{
            self.empDesc = ""
        }
        if _itemStatus != nil {
            self.itemStatus = _itemStatus
        }else{
            self.itemStatus = ""
        }
        if _chargeID != nil {
            self.chargeID = _chargeID
        }else{
            self.chargeID = ""
        }
        if _act != nil {
            self.act = _act
        }else{
            self.act = ""
        }
        if _price != nil {
            self.price = _price
        }else{
            self.price = ""
        }
        if _total != nil {
            self.total = _total
        }else{
            self.total = ""
        }
        if _totalCost != nil {
            self.totalCost = _totalCost
        }else{
            self.totalCost = ""
        }
        if _usageQty != nil {
            self.usageQty = _usageQty
        }else{
            self.usageQty = ""
        }
        if _extraUsage != nil {
            self.extraUsage = _extraUsage
        }else{
            self.extraUsage = "0"
        }
        if _unit != nil {
            self.unit = _unit
        }else{
            self.unit = ""
        }
        
        
        
    }
    
    
    
    init(_ID: String?,_name: String?,_woID: String?,_woTitle: String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        
        if _woID != nil {
            self.woID = _woID
        }else{
            self.woID = ""
        }
        
        if _woTitle != nil {
            self.woTitle = _woTitle
        }else{
            self.woTitle = ""
        }
        
        
        
        
    }
    
    
    
    init(_ID: String?,_name: String?,_contractID: String?,_contractTitle: String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        
        if _contractID != nil {
            self.contractID = _contractID
        }else{
            self.contractID = ""
        }
        
        if _contractTitle != nil {
            self.contractTitle = _contractTitle
        }else{
            self.contractTitle = ""
        }
        
        
        
        
    }
    
    
    */
    
    
    
    
    
    
    
    
}
