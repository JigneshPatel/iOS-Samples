//
//  OrderItem.swift
//  PersistanceService
//
//  Created by Vyacheslav Vdovichenko on 10/17/14.
//  Copyright (c) 2014 BACKENDLESS.COM. All rights reserved.
//

import Foundation

class OrderItem : BackendlessEntity {
    
    var ownerId : String?
    var itemName : String?
    var unitPrice : String = "$"
    var quantity = 0;
    
    // description func
    func description() -> NSString {
        return "<OrderItem> \(self.itemName) [\(self.quantity)\(self.unitPrice)] {\(self.ownerId)} "
    }
}