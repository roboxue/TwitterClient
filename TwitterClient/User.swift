//
//  User.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit

class User: NSObject {
    lazy var name: String? = {() -> String? in
        return self.dictionary["name"] as? String
    }()
    
    lazy var screenname: String? = {() -> String? in
        return self.dictionary["screen_name"] as? String
    }()
    
    lazy var profileImageUrl: NSURL? = {() -> NSURL? in
        if let url = self.dictionary["profile_image_url_https"] as? String {
            return NSURL(string: url)
        } else {
            return nil
        }
    }()
    
    lazy var tagline: String? = {() -> String? in
        return self.dictionary["description"] as? String
    }()

    lazy var id: Int? = { () -> Int? in
        return self.dictionary["id"] as? Int
    }()
    
    lazy var followersCount: Int? = { () -> Int? in
        return self.dictionary["followers_count"] as? Int
    }()
    
    lazy var friendsCount: Int? = { () -> Int? in
        return self.dictionary["friends_count"] as? Int
    }()
    
    lazy var profileBackgroundColor: String?  = { () -> String? in
        return self.dictionary["profile_background_color"] as? String
    }()
    
    lazy var statusesCount: Int? = { () -> Int? in
        return self.dictionary["statuses_count"] as? Int
    }()
    
    private let dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
    }
}
