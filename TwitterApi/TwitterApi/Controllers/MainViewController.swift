//
//  MainViewController.swift
//  TwitterApi
//
//  Created by Dogukan Tizer on 01.10.19.
//  Copyright © 2019 Dogukan Tizer. All rights reserved.
//

import UIKit
import Foundation
import OAuthSwift
import UserNotifications

class MainViewController: OAuthViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginStatusLabel: UILabel!
    
    @IBOutlet weak var accountNameText: UITextField!
    @IBOutlet weak var findFollowersButton: UIButton!
    
    public var oauthswift: OAuthSwift?
    var webViewController: WebViewController?
    var followerList: FollowerResponse? = nil
    var accountRelations: [AccountRelation]? = nil
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func loginClick(_ sender: Any) {
        
        doOAuthTwitter()
    }
   
    @IBAction func findFollowers(_ sender: Any) {
        
        self.accountNameText.endEditing(true)
        let screen_name = accountNameText.text!
        self.getAccountFollowerList(accountName: screen_name, cursor: -1)
        
    }
    
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource, customCellProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
                print("yes")
            } else {
                print("No")
            }
        }
        
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.followerList == nil){
            return 0
        }
        
        return (self.followerList?.users!.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = Bundle.main.loadNibNamed("UserTableViewCell", owner: self, options: nil)?.first as! UserTableViewCell
        
        let user = self.followerList?.users![indexPath.row]
        cell.name.text = user?.screen_name
        
        let url = URL(string: (user?.profile_image_url_https!)!)
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {    // execute on main thread
                cell.userImage.image = UIImage(data: data)
            }
        }
        task.resume()
        
        var following = false
        var following_requested = false
        
        for connection in self.accountRelations![indexPath.row].connections!{
            if(connection == "following"){
                following = true
            }
            if(connection == "following_requested"){
                following_requested = true
            }
        }
        if(following_requested){
            cell.button.setTitle("Requested", for: UIControlState.normal)
            cell.button.isEnabled = false
            cell.button.backgroundColor = UIColor.gray
            
        } else {
            if(following){
                cell.button.setTitle("Following", for: UIControlState.normal)
                cell.button.isEnabled = false
                cell.button.backgroundColor = UIColor.blue
            } else {
                cell.button.setTitle("Follow", for: UIControlState.normal)
                cell.button.isEnabled = true
                cell.button.backgroundColor = UIColor.green
            }
        }
        cell.cellDelegate = self
        
        return cell
    }
    
    func doOAuthTwitter(){
        
        let controller = WebViewController()
        controller.view = UIView(frame: UIScreen.main.bounds)  
        controller.delegate = self
        controller.viewController = self
        controller.viewDidLoad()
        webViewController = controller
        
        let oauthswift = OAuth1Swift(
            consumerKey:    Constants.twitterConsumerKey,
            consumerSecret: Constants.twitterSecretKey,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = webViewController!
        let _ = oauthswift.authorize(withCallbackURL: URL(string: Constants.callback)!,
                                     success: { credential, response, parameters in
                                        
                                        print(credential.oauthToken)
                                        print(credential.oauthTokenSecret)
                                        print(parameters["user_id"] as Any)
                                        self.loginStatusLabel.text = String(format:"Connected to : %@", parameters["screen_name"] as! CVarArg)
                                        
        },
                                     failure: { error in
                                        print(error.localizedDescription)
        })
    }
    
    
   
    /* Follower List*/
    func getAccountFollowerList(accountName: String, cursor: Int) {
        
        self.oauthswift?.client.request("https://api.twitter.com/1.1/followers/list.json", method: OAuthSwiftHTTPRequest.Method.GET, parameters: ["screen_name":accountName, "cursor":cursor, "count":5], headers: [:], body: nil, checkTokenExpiration: false,
        success: { result in
            //let jsonDict = try? result.jsonObject()
            let response = self.getFollowerArrayFromData(data: result.data)
            self.followerList = response
            self.accountRelations = nil
            
            var screenNames = ""
            for index in 0..<(self.followerList?.users?.count)! {
                
                let userName = self.followerList?.users![index].screen_name
                if(screenNames == ""){
                    screenNames = userName!
                } else {
                    screenNames = screenNames + "," + userName!
                }
            }
            self.getAccountRelation(accountNames: screenNames)
            
                                            
        },
            failure: { error in
                self.showAlert(title: "Get Follower List Error", message: error.localizedDescription)
                print(error.localizedDescription)
        })
    }
    
    func getFollowerArrayFromData(data: Data) -> FollowerArray? {
        var response: FollowerArray? = nil
        do {
            response = try JSONDecoder().decode(FollowerResponse.self, from: data)
        } catch {
            print(error)
        }
        return response
    }
    
    /* Account Relation*/
    
    func getAccountRelation(accountNames: String) {
        
        self.oauthswift?.client.request("https://api.twitter.com/1.1/friendships/lookup.json", method: OAuthSwiftHTTPRequest.Method.GET, parameters: ["screen_name":accountNames], headers: [:], body: nil, checkTokenExpiration: false,
        success: { result in
            let jsonDict = try? result.jsonObject()
            let response = self.getAccountRelationFromData(data: result.data)
            self.accountRelations = response
            
            self.tableView.reloadData()
            
            print(String(describing: jsonDict))
            
        },
        failure: { error in
            print(error.localizedDescription)
            self.showAlert(title: "Get Relation Error", message: error.localizedDescription)
        })
        
    }
    
    func getAccountRelationFromData(data: Data) -> [AccountRelation]? {
        var response: [AccountRelation]? = nil
        do {
            response = try JSONDecoder().decode(AccountRelationResponse.self, from: data)
        } catch {
            print(error)
        }
        return response
    }
    
    
    /* customCellProtocol delegate method */
    
    func follow(screen_name: String) {
        self.followUser(accountName: screen_name)
    }
    
    /* Follow user*/
    
    func followUser(accountName: String) {
        
        
        self.oauthswift?.client.request("https://api.twitter.com/1.1/friendships/create.json", method: OAuthSwiftHTTPRequest.Method.POST, parameters: ["screen_name":accountName, "follow":true], headers: [:], body: nil, checkTokenExpiration: false,
                                        success: { result in
                                            let jsonDict = try? result.jsonObject()
                                            print(String(describing: jsonDict))
                                            
                                            let screen_name = self.accountNameText.text!
                                            self.getAccountFollowerList(accountName: screen_name, cursor: -1)
                                            
                                            
                                            
        },
                                        failure: { error in
                                            print(error.localizedDescription)
                                            self.showAlert(title: "Follow Error", message: error.localizedDescription)
                                            self.showNotif(title: "Follow Error", message: "Operation finished with error")
        })
        
    }
    
    
    /* Unfollow user*/
    
    func unfollowUser(accountName: String) {
        
        
        self.oauthswift?.client.request("https://api.twitter.com/1.1/friendships/destroy.json", method: OAuthSwiftHTTPRequest.Method.POST, parameters: ["screen_name":accountName], headers: [:], body: nil, checkTokenExpiration: false,
        success: { result in
            let jsonDict = try? result.jsonObject()
            print(String(describing: jsonDict))
            
                                            
        },
        failure: { error in
            print(error.localizedDescription)
            
            self.showAlert(title: "Unfollow Error", message: error.localizedDescription)
            self.showNotif(title: "Unfollow Error", message: "Operation finished with error")
        })
        
    }
    
    
    func showAlert(title:String, message:String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNotif(title:String, message:String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "Twitter Operation"
        content.body = message
        
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
}

extension MainViewController: OAuthWebViewControllerDelegate {
    #if os(iOS) || os(tvOS)
    
    func oauthWebViewControllerDidPresent() {
        
    }
    func oauthWebViewControllerDidDismiss() {
        
    }
    #endif
    
    func oauthWebViewControllerWillAppear() {
        
    }
    func oauthWebViewControllerDidAppear() {
        
    }
    func oauthWebViewControllerWillDisappear() {
        
    }
    func oauthWebViewControllerDidDisappear() {
        // Ensure all listeners are removed if presented web view close
        oauthswift?.cancel()
    }
}
