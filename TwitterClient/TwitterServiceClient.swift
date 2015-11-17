//
//  TwitterServiceClient.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import Foundation
import BDBOAuth1Manager
import Alamofire
import SwiftSpinner
import AlamofireImage

private let twitterConsumerKey = "K9ryTdR2ukcBMY3VKhacHRrJb"
private let twitterConsumerSecret = "R8r4Om9WRL9A4ouHJjJ1U2F6FaIkviK14N7ddFM1tpmLsyorA5"
private let twitterBaseUrl = NSURL(string: "https://api.twitter.com")!
let oauthTokenUserDefaultsKey = "oauth_token"
let oauthTokenSecretUserDefaultsKey = "oauth_token_secret"
let userIdDefaultKey = "user_id"

class TwitterServiceClient: BDBOAuth1RequestOperationManager {
    private let imageCache = AutoPurgingImageCache()
    private var _userIdentifier: Int?
    private(set) var userIdentifier: Int? {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            let id = defaults.integerForKey(userIdDefaultKey)
            if id != 0 {
                _userIdentifier = id
            }
            return _userIdentifier
        }
        set {
            _userIdentifier = newValue
            if let id = newValue {
                NSUserDefaults.standardUserDefaults().setInteger(id, forKey: userIdDefaultKey)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(userIdDefaultKey)
            }

        }
    }
    private var loginCompletion: ((User?, NSError?) -> Void)!
    var currentUser: User?
    var oauthCredential: BDBOAuth1Credential? {
        if let token = NSUserDefaults.standardUserDefaults().stringForKey(oauthTokenUserDefaultsKey), secret = NSUserDefaults.standardUserDefaults().stringForKey(oauthTokenSecretUserDefaultsKey) {
            return BDBOAuth1Credential(token: token, secret: secret, expiration: nil)
        } else {
            return nil
        }
    }
    
    func loginWithCompletion(completion: (User?, NSError?) -> Void) {
        loginCompletion = completion
        getRequestToken { (url, _) -> Void in
            if let authURL = url {
                UIApplication.sharedApplication().openURL(authURL)
            }
        }
    }
    
    func getAccessToken(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (credential) -> Void in
            NSUserDefaults.standardUserDefaults().setObject(credential.token, forKey: oauthTokenUserDefaultsKey)
            NSUserDefaults.standardUserDefaults().setObject(credential.secret, forKey: oauthTokenSecretUserDefaultsKey)
            self.recoverUserSession(credential, completion: self.loginCompletion)
        }) { (error) -> Void in
            self.handleError("get access token", error: error)
        }
    }
    
    func recoverUserSession(credential: BDBOAuth1Credential, completion: (User?, NSError?) -> Void) {
        self.requestSerializer.saveAccessToken(credential)
        let handler = { (user: User?, error: NSError?) -> Void in
            if let user = user {
                self.currentUser = user
            }
            completion(user, error)
        }
        if let id = userIdentifier {
            self.showUser(id, completion: handler)
        } else {
            self.verifyCredentials(handler)
        }

    }
    
    func updateStatus(tweet: String, replyTo: Int? = nil, completion: (Tweet?, NSError?) -> Void) {
        var payload = ["status": tweet]
        if let replyTo = replyTo {
            payload["in_reply_to_status_id"] = String(replyTo)
        }
        POST("1.1/statuses/update.json", parameters: payload, success: { (operation, response) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet, nil)
        }) { (operation, error) -> Void in
            self.handleError("update status", error: error)
            completion(nil, error)
        }
    }
    
    func favorite(create: Bool, id: Int, completion: (Tweet?, NSError?) -> Void) {
        let payload = ["id": String(id)]
        let url = create ? "1.1/favorites/create.json" : "1.1/favorites/destroy.json"
        POST(url, parameters: payload, success: { (operation, response) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet, nil)
        }) { (operation, error) -> Void in
            self.handleError(create ? "fav tweet" : "un-fav tweet", error: error)
            completion(nil, error)
        }
    }
    
    func retweet(id: Int, completion: (Tweet?, NSError?) -> Void) {
        let url = "1.1/statuses/retweet/\(id).json"
        POST(url, parameters: nil, success: { (operation, response) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet, nil)
            }) { (operation, error) -> Void in
                self.handleError("retweet", error: error)
                completion(nil, error)
        }
    }
    
    func showUser(id: Int, completion: (User?, NSError?) -> Void) {
        GET("1.1/users/show.json", parameters: ["user_id": id], success: { (operation, response) -> Void in
            let user = User(dictionary: response as! NSDictionary)
            completion(user, nil)
            }) { (operation, error) -> Void in
                self.handleError("showUser", error: error)
                completion(nil, error)
        }
    }
    
    func logout() {
        userIdentifier = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(oauthTokenUserDefaultsKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(oauthTokenSecretUserDefaultsKey)
        requestSerializer.removeAccessToken()
    }
    
    func getTimeline(source: TwitterTimelineSource, since_id: Int? = nil, max_id: Int? = nil, completion: ([Tweet]?, NSError?) -> Void) {
        var parameters = ["count": "20"]
        if let max_id = max_id {
            parameters["max_id"] = String(max_id)
        }
        if let since_id = since_id {
            parameters["since_id"] = String(since_id)
        }
        
        
        GET(source.url, parameters: parameters, success: { (operation, response) -> Void in
            let tweets = Tweet.tweets(response as! [NSDictionary])
            completion(tweets, nil)
        }) { (operation, error) -> Void in
            completion(nil, error)
        }
    }
    
    private func getRequestToken(completion: (NSURL?, NSError?) -> Void) {
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "rxtwitter://oauth"), scope: nil, success: { (requestToken) -> Void in
            completion(NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)"), nil)
            }) { (error) -> Void in
                self.handleError("get request token", error: error)
                completion(nil, error)
        }
    }
    
    private func verifyCredentials(completion: (User?, NSError?) -> Void) {
        self.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation, response) -> Void in
            let user = User(dictionary: response as! NSDictionary)
            self.userIdentifier = user.id!
            completion(user, nil)
        }) { (operation, error) -> Void in
            self.handleError("verify credential", error: error)
            completion(nil, error)
        }
    }
    
    private func handleError(operationName: String, error: NSError) {
        debugPrint(error)
        SwiftSpinner.show("Encountered exception during \(operationName)", animated: true).addTapHandler({ () -> () in
            SwiftSpinner.hide()
        }, subtitle: error.localizedFailureReason)
    }
}

let TWApi = TwitterServiceClient(baseURL: twitterBaseUrl, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)

enum TwitterTimelineSource {
    case Mentions
    case Home
    
    var url: String {
        switch self {
        case .Mentions:
            return "1.1/statuses/mentions_timeline.json"
        case .Home:
            return "1.1/statuses/home_timeline.json"
        }
    }
}