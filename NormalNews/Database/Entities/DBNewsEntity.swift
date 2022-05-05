//
//  DBNewsEntity.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/4/22.
//

import Foundation
@objcMembers class DBNewsEntity : DBGeneral {
    
    var story_id: Int = 0
    var story_title : String = ""
    var author : String = ""
    var created_at: String = ""
    var created_at_i: Int = 0//NSNumber
    var story_url : String = ""
    var is_deleted: Int = 0
    
    override class func tableName() -> String{
        return "normalnews"
    }
}
