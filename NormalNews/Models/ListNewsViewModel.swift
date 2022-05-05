//
//  AddressDetailsViewModel.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/3/22.
//  Copyright © 2022 Henry Silva Company. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import NVActivityIndicatorView

class ListNewsViewModel: NSObject, UITableViewDelegate, UITableViewDataSource{
    
    private weak var context: UIViewController?
    private weak var table: UITableView?
    let cellidentifier = "cellnews"
    let refreshControl = UIRefreshControl()
    

    private var arrayNewsR = [NewsElement]()
    var callbackSelect : ((NewsElement) -> Void)?
    
    override init() {
        
    }

    convenience init(context: UIViewController,table: UITableView?) {
        self.init()
        self.context = context
        self.table = table
        self.configuretable()
    }
    
    private func configuretable(){
        if let tbl = self.table{
            tbl.register(UINib.init(nibName: "NewsViewCell", bundle: nil), forCellReuseIdentifier: cellidentifier)
            tbl.delegate = self
            tbl.dataSource = self
            tbl.separatorInset.left = 0
            tbl.separatorStyle = .singleLine
            tbl.tableFooterView = UIView()
            
            self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
            self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            tbl.refreshControl = self.refreshControl
            
        }
    }
    
    func setcontainerArray(_ array: [NewsElement]){
        self.arrayNewsR = array
        self.table!.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayNewsR.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellidentifier) as! NewsViewCell
        let element = self.arrayNewsR[indexPath.row]
        cell.lbltitle.text = element.story_title
        cell.lblautortimer.text = "\(element.author) - \(element.date_human_postago)"
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let callbackSelect  = self.callbackSelect{
            let elemetn = self.arrayNewsR[indexPath.row]
            callbackSelect(elemetn)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let item = self.arrayNewsR[indexPath.row]
            self.delete_logic_to_database(item)
            self.arrayNewsR.remove(at: indexPath.row)
            self.table!.deleteRows(at: [indexPath], with: .fade)
            
            //self.table!.reloadData()
            
        }
    }
    
    func gedata_fromurl(isfromPulltoRefresh: Bool = false){
       
        let urlsv = "\(KString.urldefaultRoot)/search_by_date?query=mobile"
        
        if !isfromPulltoRefresh{
            self.startani()
        }
        
        Alamofire.request(urlsv, method: .get,encoding: JSONEncoding.default).responseJSON{ [weak self] response in
            
            guard let weakself = self else { return }
            if !isfromPulltoRefresh{
                weakself.stopani()
            }else{
                if let rfc = weakself.table!.refreshControl {
                    rfc.endRefreshing()
                }
            }
            
            switch response.result {
            case .success(let value):
                
                if response.response?.statusCode == 200{
                    if let JSON = value as? NSDictionary{
                        if let hitsarray = JSON.object(forKey: "hits") as? [NSDictionary]{
                            
                            var arrayE = [NewsElement]()
                            for hit in hitsarray {
                                let new_newelement = NewsElement()
                                new_newelement.story_id = hit.object(forKey: "story_id") as? Int ?? 0
                                new_newelement.created_at_i = hit.object(forKey: "created_at_i") as? Int ?? 0
                                
                                new_newelement.story_title = hit.object(forKey: "story_title") as? String ?? ""
                                new_newelement.author = hit.object(forKey: "author") as? String ?? ""
                                new_newelement.created_at = hit.object(forKey: "created_at") as? String ?? ""
                                new_newelement.story_url = hit.object(forKey: "story_url") as? String ?? ""
                                arrayE.append(new_newelement)
                                
                            }
                            weakself.check_insert_update_to_database(arrayE)
                            weakself.setcontainerArray(weakself.get_news_from_database())
                           
                        }
                        
                    }
                }else{
                    print("some error")
                    
                }
                
                
            case .failure(let error):
            
                print("failure \(error)")
            }
        }
    }
    
    func stopani(){
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    func startani(){
        let activityData = ActivityData(size: CGSize(width: 50, height: 50), message: "Loading...", messageFont: UIFont.systemFont(ofSize: 12), messageSpacing: 10.0, type: .ballSpinFadeLoader, color: .white, padding: 0, displayTimeThreshold: 10, minimumDisplayTime: 1, backgroundColor: UIColor.black.withAlphaComponent(0.7), textColor: .white)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {

        // somewhere in your code you might need to call:
        self.gedata_fromurl(isfromPulltoRefresh: true)
        
    }
    
    
    func get_news_from_database() -> [NewsElement]{
        print(#function)
        
        if let arraynewsdb = DBNewsEntity.selectWithCondition(" is_deleted = 0 order by created_at_i desc") as? [DBNewsEntity], arraynewsdb.count > 0 {
            
            return NewsElement.get_ArrayNewsElement_from_ArrayDBNewsEntity(arraynewsdb)
            
        }
        return [NewsElement]()
    }
    
    func check_insert_update_to_database(_ array: [NewsElement]){
        print(#function)
        for item in array {
            if let arrayTOfirst = DBNewsEntity.selectWithCondition(" story_id = \(item.story_id) ") as? [DBNewsEntity], arrayTOfirst.count > 0,let firtnew = arrayTOfirst.first {
                firtnew.story_title = item.story_title
                firtnew.author = item.author
                firtnew.created_at = item.created_at
                firtnew.created_at_i = item.created_at_i
                firtnew.story_url = item.story_url
                let _ = DBNewsEntity.update(firtnew, condition: " story_id = \(firtnew.story_id) " )
                print("story_id = \(firtnew.story_id) updated")
            }else{
                let firtnew = DBNewsEntity()
                firtnew.story_id = item.story_id
                firtnew.story_title = item.story_title
                firtnew.author = item.author
                firtnew.created_at = item.created_at
                firtnew.created_at_i = item.created_at_i
                firtnew.story_url = item.story_url
                firtnew.is_deleted = 0
                let _ = DBNewsEntity.insert(firtnew)
                print("story_id = \(firtnew.story_id) inserted")
            }
        }
    }
    
    func delete_logic_to_database(_ item : NewsElement){
        print(#function)
        if let arrayTOfirst = DBNewsEntity.selectWithCondition(" story_id = \(item.story_id) ") as? [DBNewsEntity], arrayTOfirst.count > 0,let firtnew = arrayTOfirst.first {
            firtnew.is_deleted = 1
            let _ = DBNewsEntity.update(firtnew, condition: " story_id = \(firtnew.story_id) " )
            print("story_id = \(firtnew.story_id) logic deleted")
        }
    }
    
}
