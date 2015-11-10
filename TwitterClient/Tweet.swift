//
//  Tweet.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User? {
        if let userD = self.dictionary["user"] as? NSDictionary {
            return User(dictionary: userD)
        } else {
            return nil
        }
    }
    
    var text: String? {
        return self.dictionary["text"] as? String
    }
    
    var createdAt: NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        return formatter.dateFromString((self.dictionary["created_at"] as! String))
    }
    
    var id: Int? {
        return self.dictionary["id"] as? Int
    }
    
    var favorited: Bool? {
        return self.dictionary["favorited"] as? Bool
    }
    
    var favouritesCount: Int? {
        return self.dictionary["favorite_count"] as? Int
    }
    
    var retweeted: Bool? {
        return self.dictionary["retweeted"] as? Bool
    }
    
    var retweetCount: Int? {
        return self.dictionary["retweet_count"] as? Int
    }
    
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
    }
    
    class func tweets(array: [NSDictionary]) -> [Tweet] {
        return array.map { (dictionary) -> Tweet in
            Tweet(dictionary: dictionary)
        }
    }
}


protocol TweetDelegate {
    func retweet(tweet: Tweet)
    
    func reply(tweet: Tweet)
    
    func fav(tweet: Tweet)
}