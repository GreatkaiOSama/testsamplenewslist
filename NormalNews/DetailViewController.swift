//
//  DetailViewController.swift
//  NormalNews
//
//  Created by Henry Silva Olivo on 5/4/22.
//

import UIKit
import WebKit

class DetailViewController: UIViewController,WKNavigationDelegate {

    var news_element : NewsElement?
    
    var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let letnews_element = self.news_element,letnews_element.story_url.count > 0 {
            self.loadwkwebview(letnews_element.story_url)
        }
        
    }
    
    func loadwkwebview(_ urlstring : String){
                
        if let url = URL(string: urlstring) {
            let conf = WKWebViewConfiguration.init()
            //WKWebView.init()
            webview = WKWebView.init(frame: CGRect.init(), configuration: conf)
            webview.translatesAutoresizingMaskIntoConstraints = false
            webview.navigationDelegate = self
            //webview.uiDelegate = self
            self.view.addSubview(webview)
            
            webview.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            webview.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            webview.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            webview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
            
            webview.scrollView.bounces = false
            var requesobj = URLRequest.init(url: url)
            requesobj.cachePolicy = .reloadIgnoringLocalCacheData
            webview.load(requesobj)
            webview.scrollView.isScrollEnabled = true
            webview.scrollView.contentMode = .scaleAspectFit
        }

        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finish Load WKWebview")
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            decisionHandler(WKNavigationActionPolicy.cancel)
            
            if let url = navigationAction.request.url {
                if url.description.range(of: "http://") != nil || url.description.range(of: "https://") != nil || url.description.range(of: "mailto:") != nil || url.description.range(of: "tel:") != nil  {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                }
            }
            return
        }
        print("no link")
        decisionHandler(WKNavigationActionPolicy.allow)
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
