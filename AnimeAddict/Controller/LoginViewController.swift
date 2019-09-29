
//
//  LoginViewController.swift
//  AnimeAddict
//
//  Created by Tony Mark on 4/17/19.
//  Copyright © 2019 Tony Mark. All rights reserved.
//

import UIKit
import Dispatch
import WebKit

let getProfileNotificationKey = "gotData"
let bgColor = UIColor(red: 31/255, green: 33/255, blue: 36/255, alpha: 1)
let cellColor = UIColor.black

struct CellData {
    let mal_id: Int?
    let title: String?
    let image: UIImage?
    let watching_status: Int?
    let score: Int?
    let watched_episodes: Int?
    let total_episodes: Int?
    let tags: String?
}

class LoginViewController : UIViewController, WKNavigationDelegate {
    var container: ContainerController?
    var embeddedViewController: ContainerController!
    
    var webView: WKWebView!
    let urlIn = URL(string: "https://myanimelist.net/login.php")!
    var profile: String?
    var csrf: String?
    
    var cookies = [HTTPCookie]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(cookies.count, profile)
        webView = WKWebView()
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        webView.navigationDelegate = self
        webView.load(URLRequest(url: urlIn))
        webView.allowsBackForwardNavigationGestures = true
        webView.frame = self.view.bounds
    }
    
    @IBAction func LoginPressed(_ sender: Any) {
        let username = embeddedViewController.UsernameTextField.text
        let password = embeddedViewController.PasswordTextField.text
        if webView.url?.absoluteString.range(of: "https://myanimelist.net/login.php") != nil {
            //
        } else {
            webView.load(URLRequest(url: urlIn))
        }
        self.view.addSubview(webView)
        
        let fillForm = String(format: "document.getElementById('loginUserName').value = '%@';document.getElementById('password').value =  '%@'", username!, password!)
        webView.evaluateJavaScript(fillForm)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ContainerController {
            if let vc = segue.destination as? ContainerController, segue.identifier == "EmbededSegue" {
                self.embeddedViewController = vc
            }
        }
    }
    
    @objc func goToDifferentView() {
        self.performSegue(withIdentifier: "segue", sender: self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            print("### URL:", self.webView.url!)
            if self.webView.url!.absoluteString.range(of: "https://myanimelist.net") != nil {
                let cookieNames = ["MALHLOGSESSID", "MALSESSIONID", "is_logged_in"]
                WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
                    for cookie in cookies {
                        if cookieNames.contains(cookie.name) {
                            self.cookies.append(cookie)
                        }
                    }
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.getElementsByClassName('username')[0].innerText") {(result, error) in
            guard error == nil else {
                print(error!)
                return
            }
            self.profile = result as! String
        }
        webView.evaluateJavaScript("document.getElementsByTagName('meta')[name='csrf_token'].content") {(result, error) in
            guard error == nil else {
                print(error!)
                return
            }
            self.csrf = result as! String
            
            if self.cookies.count == 3 && self.profile != nil {
                self.createTableView()
            }
            
            for cookie in self.cookies {
                print(cookie.name)
            }
            print(self.profile)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func createTableView() {
        let navBarController: NavBarController = self.storyboard?.instantiateViewController(withIdentifier: "NavBarView") as! NavBarController
        let tabBarController: TabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarView") as! TabBarController
        let watchController: WatchViewController = self.storyboard?.instantiateViewController(withIdentifier: "WatchView") as! WatchViewController
        let allController: AllViewController = self.storyboard?.instantiateViewController(withIdentifier: "AllView") as! AllViewController
        let airingController: AiringViewController = self.storyboard?.instantiateViewController(withIdentifier: "AiringView") as! AiringViewController
        
        navBarController.profile = self.profile!
        watchController.profile = self.profile!
        watchController.cookies = self.cookies
        watchController.csrf = self.csrf!
        allController.profile = self.profile!
        allController.cookies = self.cookies
        allController.csrf = self.csrf!
        airingController.profile = self.profile!
        airingController.cookies = self.cookies
        airingController.csrf = self.csrf!
        
        navBarController.addChild(tabBarController)
        navBarController.viewControllers.removeFirst()
        tabBarController.viewControllers?.removeAll()
        tabBarController.viewControllers?.append(watchController)
        tabBarController.viewControllers?.append(allController)
        tabBarController.viewControllers?.append(airingController)
        
        let logoutButton = UIBarButtonItem(title: "logout", style: .plain, target: self, action: #selector(logout))
        
        navBarController.navigationBar.topItem?.rightBarButtonItem = logoutButton

        self.present(navBarController, animated: true)
        self.webView.removeObserver(self, forKeyPath: "URL")
        self.webView.removeFromSuperview()
    }
    
    @objc func logout(_ sender: UIBarButtonItem) {
        let sem = DispatchSemaphore(value: 1)
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
            sem.signal()
        }
        self.webView.configuration.processPool = WKProcessPool()
        
        self.cookies = []
        self.profile = nil
        sem.wait()
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
    }
}

