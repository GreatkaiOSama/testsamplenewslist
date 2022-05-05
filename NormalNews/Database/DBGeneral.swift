//
//  DBGeneral.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/4/22.
//

import UIKit
import FMDB

class DBGeneral: NSObject {
    
    var uniqueID: Int = 0
    
    static func getAttributes(_ object: DBGeneral) -> Array<DBAttributeEnumerator>{
        
        let mirrored_object = Mirror(reflecting: object)
        
        var attributes = Array<DBAttributeEnumerator>()
        for (index, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String? {
                let enumerator = DBAttributeEnumerator()
                enumerator.index = index
                enumerator.name = property_name
                enumerator.value = String(describing: attr.value)
                enumerator.type = String(describing: type(of: (attr.value)))
                attributes.append(enumerator)
            }
        }
        
        return attributes
    }
    
    required override init(){
        super.init()
    }
    
    class func tableName() -> String{
        return ""
    }
    
    class func createTable() -> Bool{
        return self.internalCreateTable(self.init())
    }
    
    class func dropTable() -> Bool {
        return self.internalDropTable(self.init())
    }
    
    class func countRowsWithCondition(_ condition: String?) -> Int{
        var count: Int = 0
        
        var query = "SELECT COUNT(*) FROM \(self.tableName())"
        
        if let cond = condition{
            query += " WHERE " + cond
        }
        
        let resultSet = self.customSelect(query)
        
        if let rs = resultSet{
            for result in rs{
                let tmp_result : NSDictionary = result
                count = (tmp_result.object(forKey: "COUNT(*)") as AnyObject) as? Int ?? 0
            }
        }
        
        return count
    }
    
    class func countRows() -> Int{
        return countRowsWithCondition(nil)
    }
    
    class func deleteEverything() -> Bool{
        return self.internalDelete(nil)
    }
    
    class func deleteWithCondition(_ condition: String?) -> Bool{
        return self.internalDelete(condition)
    }
    
    class func insert(_ object: DBGeneral) -> Bool{
        return self.internalInsert(object)
    }
    
    class func update(_ object: DBGeneral, condition: String) -> Bool{
        return  self.internalUpdate(object, condition: condition)
    }
    
    class func selectWithCondition(_ condition: String) -> Array<DBGeneral>?{
        return self.internalSelect(condition)
    }
    
    class func selectWithOrderBy(fields: String) -> Array<DBGeneral>? {
        return self.internalOrderBy(fields: fields)
    }
    
    class func selectEverything() -> Array<DBGeneral>?{
        return self.internalSelect(nil)
    }
    
    //todo menos select
    class func customQuery(_ query: String) -> Bool{
        return self.customQuery(query, values: nil)
    }
    
    
    class func customQuery(_ query: String, values: [AnyObject]?) -> Bool{
        var success: Bool = false
        DatabaseHelper.sharedInstance.databaseQueue?.inDatabase({ (db) -> Void in
            if (db.open()){
                if let vals = values{
                    success = (db.executeUpdate(query, withArgumentsIn: vals))
                }
                else{
                    success = (db.executeUpdate(query, withArgumentsIn: [AnyObject]()))
                }
            }
            db.close()
        })
        
        return success
    }
    
    class func customSelect(_ query: String) -> [NSDictionary]?{
        
        var results: [NSDictionary]?
        DatabaseHelper.sharedInstance.databaseQueue?.inDatabase({ (db) -> Void in
            do{
                if (db.open()){
                    let resultSet = try db.executeQuery(query, values: nil)
                    results = self.convertResultSetToArray(resultSet)
                }
                db.close()
            }
            catch{}
        })
        
        return results
    }
    
    //MARK: - DROP
    private static func internalDropTable(_ object: DBGeneral) -> Bool{
        
        var result: Bool = false
        DatabaseHelper.sharedInstance.databaseQueue?.inDatabase({ (db) -> Void in
            let query = "drop table if exists \(self.tableName())"
            db.open()
            result = (db.executeUpdate(query, withArgumentsIn: [AnyObject]()))
            db.close()
        })
        return result
        
    }
    
    
    //MARK: - CREATE
    
    private static func internalCreateTable(_ object: DBGeneral) -> Bool{
        
        var result: Bool = false
        
        DatabaseHelper.sharedInstance.databaseQueue?.inDatabase({ (db) -> Void in
            
            let dummyObj = object
            let attributes = self.getAttributes(dummyObj)
            
            var query = "CREATE TABLE IF NOT EXISTS \(self.tableName()) (uniqueID INTEGER PRIMARY KEY ASC"
            
            for attr in attributes{
                query += ", \"\(attr.name)\" \(attr.type)"
            }
            
            query += ")"
            
            db.open()
            result = (db.executeUpdate(query, withArgumentsIn: [AnyObject]()))
            db.close()
        })
        
        return result
    }
    
    // PRAGMA: - SELECT
    private static func internalSelect(_ condition: String?) -> Array<DBGeneral>?{
        var query = "SELECT * FROM \(self.tableName())"
        
        if let cond = condition{
            query += " WHERE " + cond
        }
        
        return storeSelectInArray(query)
    }
    
    private static func storeSelectInArray(_ query: String?) -> Array<DBGeneral>?{
        var results: [NSDictionary] = Array<NSDictionary>()
        
        DatabaseHelper.sharedInstance.databaseQueue?.inDatabase({ (db) -> Void in
            do{
                if (db.open()){
                    if let _ = query {
                        let resultSet = try db.executeQuery(query!, values: nil)
                        results = convertResultSetToArray(resultSet)
                        resultSet.close()
                    }
                    
                }
                db.close()
            }
            catch{}
        })
        
        var arrayAll: Array<DBGeneral>
        
        if results.count > 0 {
            
            arrayAll = Array<DBGeneral>()
            
            for result in results{
                let obj = self.init()
                
                let attributes = DBGeneral.getAttributes(obj)
                for attr in attributes{
    
                    let value = result.object(forKey: attr.name)
                    if value is NSNull{
                        if attr.type == "INTEGER" || attr.type == "REAL"{
                            obj.setValue(0, forKey: attr.name)
                        }
                        else{
                            obj.setValue(nil, forKey: attr.name)
                        }
                    }
                    else if value is String{
                        let finalValue : String = (value as! String).replacingOccurrences(of: "\\n", with: "").replacingOccurrences(of: "\\", with: "")
                        
                        obj.setValue(finalValue, forKey: attr.name)
                    }
                    else{
                        obj.setValue(value, forKey: attr.name)
                    }
                }
                
                arrayAll.append(obj)
            }
            
            return arrayAll;
        }
        else{
            return nil
        }
    }
    
    private static func convertResultSetToArray(_ resultSet: FMResultSet) -> [NSDictionary]{
        var results: [NSDictionary] = Array<NSDictionary>()
        
        while resultSet.next(){
            if let _ = resultSet.resultDictionary {
                let tmp : NSDictionary = resultSet.resultDictionary! as NSDictionary
                results.append(tmp)
            }
            
        }
        
        resultSet.close()
        
        return results
    }
    
    //MARK:- INSERT
    
    private static func internalInsert(_ object: DBGeneral) -> Bool{
        
        var success: Bool = false
        
        DatabaseHelper.sharedInstance.databaseQueue?.inDatabase({ (db) -> Void in
            do{
                let attributes = self.getAttributes(object)
                
                var query = "INSERT INTO \(self.tableName()) ("
                var parameters = ""
                var values = ""
                var valuesArray = Array<AnyObject>()
                
                for attr in attributes{
                    parameters += "\"" + attr.name + "\", "
                    values += "?, "
                    
                    if (attr.value == "NULL"){
                        valuesArray.append(NSNull()) ///todo: descomentar
                    }
                    else{
                        if attr.value.hasPrefix("Optional("){
                            //var newValue = attr.value.substringFromIndex(attr.value.startIndex.advancedBy(10))
                            //newValue = newValue.substringToIndex(newValue.endIndex.advancedBy(-2))
                            
                            if (attr.type == "REAL" && attr.type != nil){
                                var newValue = attr.value.substring(from: attr.value.index(attr.value.startIndex, offsetBy: 9))
                                newValue = newValue.substring(to: newValue.index(newValue.endIndex, offsetBy: -1))
                                valuesArray.append(Double(newValue)! as AnyObject)
                            }
                            else{
                                var newValue = attr.value.substring(from: attr.value.index(attr.value.startIndex, offsetBy: 10))
                                newValue = newValue.substring(to: newValue.index(newValue.endIndex, offsetBy: -2))
                                valuesArray.append(newValue as AnyObject)
                            }
                        }
                        else{
                            if DBAttributeEnumerator.typeIsReal(attr.type){
                                valuesArray.append(Double(attr.value)! as AnyObject)
                            }
                            else{
                                valuesArray.append(attr.value as AnyObject)
                            }
                            
                        }
                    }
                }
                
                db.open()
                if (parameters.distance(from: parameters.startIndex, to: parameters.endIndex) > 3){
                    parameters = parameters.substring(to: parameters.index(parameters.endIndex, offsetBy: -2))
                    values = values.substring(to: values.index(values.endIndex, offsetBy: -2))
                    query += parameters + ") VALUES (" + values + ")"
                    try db.executeUpdate(query, values: valuesArray)
                    success = true
                }
                else{
                    query = ""
                    success = false
                }
                
                
            }
            catch{
                success = false;
            }
            db.close()
        })
        
        return success
    }
    
    //MARK: - DELETE
    
    private static func internalDelete(_ condition: String?) -> Bool{
        var result: Bool = false
        
        DatabaseHelper.sharedInstance.databaseQueue?.inDatabase({ (db) -> Void in
            db.open()
            
            var query = "DELETE FROM \(self.tableName())"
            
            if let cond = condition{
                query += " WHERE " + cond
            }
            
            result = (db.executeUpdate(query, withArgumentsIn: [AnyObject]()));
            db.close()
        })
        
        return result
    }
    
    //MARK:- UPDATE
    
    private static func internalUpdate(_ object: DBGeneral, condition : String) -> Bool{
        
        var success: Bool = false
        
        DatabaseHelper.sharedInstance.databaseQueue?.inDatabase({ (db) -> Void in
            do{
                let attributes = self.getAttributes(object)
                
                var query = "UPDATE \(self.tableName()) SET "
                var parameters = ""
                var values = ""
                var valuesArray = Array<AnyObject>()
                
                for attr in attributes{
                    parameters += "\"" + attr.name + "\" = ?, "
                    values += "?, "
                    
                    if (attr.value == "NULL"){
                        valuesArray.append(NSNull())
                    }
                    else{
                        
                        if attr.value.hasPrefix("Optional("){
                            
                            if (attr.type == "REAL" && attr.type != nil){
                                var newValue = attr.value.substring(from: attr.value.index(attr.value.startIndex, offsetBy: 9))
                                newValue = newValue.substring(to: newValue.index(newValue.endIndex, offsetBy: -1))
                                valuesArray.append(Double(newValue)! as AnyObject)
                            }
                            else{
                                var newValue = attr.value.substring(from: attr.value.index(attr.value.startIndex, offsetBy: 10))
                                newValue = newValue.substring(to: newValue.index(newValue.endIndex, offsetBy: -2))
                                valuesArray.append(newValue as AnyObject)
                            }
                        }
                        else{
                            if DBAttributeEnumerator.typeIsReal(attr.type){
                                valuesArray.append(Double(attr.value)! as AnyObject)
                            }
                            else{
                                valuesArray.append(attr.value as AnyObject)
                            }
                            
                        }
                        
                    }
                }
                
                db.open()
                if (parameters.distance(from: parameters.startIndex, to: parameters.endIndex) > 3){
                    parameters = parameters.substring(to: parameters.index(parameters.endIndex, offsetBy: -2))
                    values = values.substring(to: values.index(values.endIndex, offsetBy: -2))
                    query += parameters + " WHERE " + condition
                    try db.executeUpdate(query, values: valuesArray)
                    success = true
                }
                else{
                    query = ""
                    success = false
                }
                
                
            }
            catch{
                success = false;
            }
            db.close()
        })
        
        return success
    }
    
    //MARK: - ORDER BY
    private static func internalOrderBy(fields: String) -> Array<DBGeneral>?{
        var query = "SELECT * FROM \(self.tableName())"
        
        query += " ORDER BY " + fields
        
        
        return storeSelectInArray(query)
    }
    
}
