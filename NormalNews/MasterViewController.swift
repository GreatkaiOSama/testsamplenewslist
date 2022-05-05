//
//  MasterViewController.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/3/22.
//

import UIKit

class MasterViewController: UIViewController {

    var newsviewmodel : ListNewsViewModel?
    
    @IBOutlet var tbldata: UITableView!
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureView()
    }
    
    private func configureView(){
        //self.title = KString.listaddressScreen
        
        self.newsviewmodel = ListNewsViewModel.init(context: self, table: self.tbldata)
        self.newsviewmodel!.setcontainerArray(self.newsviewmodel!.get_news_from_database())
        self.newsviewmodel!.gedata_fromurl()
        self.newsviewmodel!.callbackSelect = { [weak self] (itemnews) -> Void in
            guard let weakself = self else { return }
            if itemnews.story_url.count > 0 {
                weakself.goToDetail(itemnews)
            }else{
                weakself.alertdialog_no_url_pagedatail()
            }
            
        }
        
        
    }
    
    private func alertdialog_no_url_pagedatail(){
        let alert = UIAlertController(title: "Hacker News", message: "This news does not have url to show detail", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func goToDetail(_ news : NewsElement){
        let da = DetailViewController.init(nibName: "DetailViewController", bundle: nil)
        da.news_element = news
        self.navigationController?.pushViewController(da, animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
