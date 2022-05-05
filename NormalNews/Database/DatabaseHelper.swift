//
//  DatabaseHelper.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/4/22.
//

import UIKit
import FMDB

class DatabaseHelper: NSObject {
    
    
    static let sharedInstance = DatabaseHelper()
    
    var databaseQueue: FMDatabaseQueue?
    
    enum DatabaseQueue: Error {
        case datastoreConnectionError
        case insertError
        case deleteError
        case searchError
        case nilInData
        case otherError
    }
    
    private override init(){
        super.init()
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbCompletePath = "\(path)/database1.sqlite"
        databaseQueue = FMDatabaseQueue(path: dbCompletePath)
        
        print("DATABASE = \(dbCompletePath)")
    }
    
    func beginTableManage() {
        //VERSIONING BREAK DATABASE
        let db: FMDatabase = FMDatabase(path: databaseQueue?.path!)
        db.open()
        print("FMDBUserVersion = \(db.userVersion)")

        print("new version DB = \(KString.kDataBaseVersion)")
        let userversionbd : UInt32 = db.userVersion
        let controldbVersion : UInt32 = UInt32(KString.kDataBaseVersion)
      
        if userversionbd < controldbVersion  {
         
            db.userVersion = UInt32(KString.kDataBaseVersion)
            db.close()
            dropTables()
            print("DROP AND CREATE TABLES")
            
        }else{
            db.close()
            
        }
        createTables()
        
        
    }
    
    func createTables(){
        DBNewsEntity.createTable()
    }
    
    func dropTables(){
        DBNewsEntity.dropTable()
    }
}
