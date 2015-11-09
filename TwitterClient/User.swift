//
//  User.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String? {
        return dictionary["name"] as? String
    }
    var screenname: String? {
        return dictionary["screen_name"] as? String
    }
    var profileImageUrl: String? {
        return dictionary["profile_image_url"] as? String
    }
    var tagline: String? {
        return dictionary["descirption"] as? String
    }

    private let dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
    }

}
