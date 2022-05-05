//
//  basededatos.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/4/22.
//

import Foundation

class DBInitProcessinstance: NSObject {
    
    static let sharedInstance = DBInitProcessinstance()
    
    func start(){
        //create databasehelper
        
        DatabaseHelper.sharedInstance.beginTableManage()
    }
}


