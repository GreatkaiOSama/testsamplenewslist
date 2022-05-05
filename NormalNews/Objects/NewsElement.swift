//
//  NewsElement.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/3/22.
//

import Foundation


class NewsElement : NSObject{
    
    var story_id : Int = 0
    var story_title = ""
    var author = ""
    var created_at = ""
    var created_at_i :Int = 0
    var story_url = ""
    var is_deleted: Int = 0
    
    var date_human_postago = ""
    
    static func get_ArrayNewsElement_from_ArrayDBNewsEntity(_ array: [DBNewsEntity]) -> [NewsElement]{
        var newarray = [NewsElement]()
        for item in array {
            let newitem = NewsElement()
            newitem.story_id = item.story_id
            newitem.story_title = item.story_title
            newitem.author = item.author
            newitem.created_at = item.created_at
            newitem.created_at_i = item.created_at_i
            newitem.story_url = item.story_url
            newitem.is_deleted = item.is_deleted
            let dateconverted = Utils.convert_timestamp_to_date(newitem.created_at_i)
            newitem.date_human_postago = dateconverted.timeAgoDisplay()
            
            print(newitem.date_human_postago)
            newarray.append(newitem)
        }
        return newarray
    }
    
}
