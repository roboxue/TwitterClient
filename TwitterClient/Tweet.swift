//
//  Tweet.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    lazy var user: User? = {() -> User? in
        if let userD = self.dictionary["user"] as? NSDictionary {
            return User(dictionary: userD)
        } else {
            return nil
        }
    }()
    
    lazy var text: String? = { () -> String? in
        return self.dictionary["text"] as? String
    }()
    
    lazy var createdAt: NSDate? = { () -> NSDate? in
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        return formatter.dateFromString((self.dictionary["created_at"] as! String))
    }()
    
    private let dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
    }
    
    class func tweets(array: [NSDictionary]) -> [Tweet] {
        return array.map { (dictionary) -> Tweet in
            Tweet(dictionary: dictionary)
        }
    }
}
