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

private let twitterConsumerKey = "K9ryTdR2ukcBMY3VKhacHRrJb"
private let twitterConsumerSecret = "R8r4Om9WRL9A4ouHJjJ1U2F6FaIkviK14N7ddFM1tpmLsyorA5"
private let twitterBaseUrl = NSURL(string: "https://api.twitter.com")!


class TwitterServiceClient: BDBOAuth1RequestOperationManager {
    private var loginCompletion: ((User?, NSError?) -> Void)!
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
            self.requestSerializer.saveAccessToken(credential)
            self.verifyCredentials(self.loginCompletion)
        }) { (error) -> Void in
            self.handleError("get access token", error: error)
        }
    }
    
    func logout() {
        requestSerializer.removeAccessToken()
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
