//
//  DBAttributeEnumerator.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/4/22.
//

import UIKit

class DBAttributeEnumerator: NSObject {
    
    var name: String = ""
    var type: String = ""{
        didSet {
            if type == "Optional<String>" || type == "String"{
                self.type = "TEXT"
            }
            else if type == "Optional<Int>" || type == "Int"{
                self.type = "INTEGER"
            }
            else if DBAttributeEnumerator.typeIsReal(type){
                self.type = "REAL"
            }
            else if type == "Optional<NSDate>" || type == "NSDate"{
                self.type = "REAL"
            }
            else{
                self.type = "TEXT"
            }
        }
    }
    var value: String = ""{
        didSet{
            if (self.value == nil || self.value == "nil"){
                self.value = "NULL"
            }
        }
    }
    var index: Int = 0
    
    static func typeIsReal(_ type: String) -> Bool{
        return type == "Optional<Double>" || type == "Double" || type == "Optional<Float>" || type == "Float" || type == "Optional<NSNumber>" || type == "NSNumber"
        
    }
}
