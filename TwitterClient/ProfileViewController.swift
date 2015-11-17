//
//  ProfileViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/16/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import SwiftSpinner
import AlamofireImage

class ProfileViewController: TWBaseViewController {
    private var _topBackgroundView: UIImageView!
    private var _profileImageView: UIImageView!
    private var _nameLabel: UILabel!
    private var _screennameLabel: UILabel!
    private var _taglineLabel: UILabel!
    private var _tweetsCountLabel: UILabel!
    private var _followingCountLabel: UILabel!
    private var _followersCountLabel: UILabel!
    private var _menuBarButton: UIBarButtonItem!

    override func initializeUI() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = TWBackgroundColor
    }
    
    override func addSubviews() {
        view.addSubview(topBackgroundView)
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(screennameLabel)
        view.addSubview(taglineLabel)
        view.addSubview(tweetsCountLabel)
        view.addSubview(followingCountLabel)
        view.addSubview(followersCountLabel)
        navigationItem.leftBarButtonItem = menuBarButton
    }
    
    override func addLayouts() {
        topBackgroundView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(view.snp_width).dividedBy(3)
        }
        profileImageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topBackgroundView.snp_bottom).offset(-TWSpanSize * 4)
            make.left.equalTo(view).offset(TWSpanSize * 2)
            make.width.equalTo(73)
            make.height.equalTo(73)
        }
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(profileImageView.snp_bottom).offset(TWSpanSize * 2)
            make.left.equalTo(profileImageView)
        }
        screennameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp_bottom).offset(TWSpanSize)
            make.left.equalTo(profileImageView)
        }
        taglineLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(screennameLabel.snp_bottom)
            make.left.equalTo(profileImageView)
            make.right.lessThanOrEqualTo(view).offset(-TWSpanSize)
        }
        tweetsCountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(taglineLabel.snp_bottom).offset(TWSpanSize)
            make.left.equalTo(profileImageView)
        }
        followingCountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(tweetsCountLabel)
            make.left.equalTo(tweetsCountLabel.snp_right).offset(TWSpanSize * 4)
        }
        followersCountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(tweetsCountLabel)
            make.left.equalTo(followingCountLabel.snp_right).offset(TWSpanSize * 4)
        }
    }
    
    override func refreshUI() {
        let handler = { (user: User) in
            if let backgroundColor = user.profileBackgroundColor {
                self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#" + backgroundColor)
                self.topBackgroundView.backgroundColor = UIColor(rgba: "#" + backgroundColor)
            } else {
                self.navigationController?.navigationBar.barTintColor = TWBlue
                self.topBackgroundView.backgroundColor = TWBlue
            }
            self.profileImageView.af_setImageWithURL(user.profileImageUrl!, filter: RoundedCornersFilter(radius: 2.0))
            self.nameLabel.text = user.name
            self.screennameLabel.text = "@" + user.screenname!
            self.taglineLabel.text = user.tagline
            self.tweetsCountLabel.attributedText = self.composeAttributeString(String(user.statusesCount!), right: "TWEET")
            self.followingCountLabel.attributedText = self.composeAttributeString(String(user.friendsCount!), right: "FOLLOWING")
            self.followersCountLabel.attributedText = self.composeAttributeString(String(user.statusesCount!), right: "FOLLOWER")
        }
        
        if let user = TWApi.currentUser {
            handler(user)
        } else if let credential = TWApi.oauthCredential {
            SwiftSpinner.show("Loading", animated: true)
            TWApi.recoverUserSession(credential, completion: { (user, error) -> Void in
                if let user = user {
                    SwiftSpinner.hide()
                    handler(user)
                }
            })
        } else {
            // Not logged in
        }
    }
}

extension ProfileViewController {
    private func composeAttributeString(left: String, right: String) -> NSAttributedString {
        let countText = NSMutableAttributedString(string: left, attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: TWContentFont])
        countText.appendAttributedString(NSAttributedString(string: " " + right, attributes: [NSForegroundColorAttributeName: TWSecondaryTextColor, NSFontAttributeName: TWContentFont]))
        return countText
    }
}

extension ProfileViewController {
    var topBackgroundView: UIImageView {
        if _topBackgroundView == nil {
            let v = UIImageView()
            _topBackgroundView = v
        }
        return _topBackgroundView
    }
    
    var profileImageView: UIImageView {
        if _profileImageView == nil {
            let v = UIImageView()
            _profileImageView = v
        }
        return _profileImageView
    }
    
    var nameLabel: UILabel {
        if _nameLabel == nil {
            let v = UILabel()
            v.font = TWContentFontBold
            _nameLabel = v
        }
        return _nameLabel
    }
    
     var screennameLabel: UILabel {
        if _screennameLabel == nil {
            let v = UILabel()
            v.font = TWContentFont
            v.textColor = TWSecondaryTextColor
            _screennameLabel = v
        }
        return _screennameLabel
    }

    var taglineLabel: UILabel {
        if _taglineLabel == nil {
            let v = UILabel()
            v.font = TWContentFont
            v.textColor = TWSecondaryTextColor
            _taglineLabel = v
        }
        return _taglineLabel
    }

    var tweetsCountLabel: UILabel {
        if _tweetsCountLabel == nil {
            let v = UILabel()
            _tweetsCountLabel = v
        }
        return _tweetsCountLabel
    }

    var followingCountLabel: UILabel {
        if _followingCountLabel == nil {
            let v = UILabel()
            _followingCountLabel = v
        }
        return _followingCountLabel
    }
    
    var followersCountLabel: UILabel {
        if _followersCountLabel == nil {
            let v = UILabel()
            _followersCountLabel = v
        }
        return _followersCountLabel
    }
    
    var menuBarButton: UIBarButtonItem {
        if _menuBarButton == nil {
            let v = UIBarButtonItem(image: UIImage(named: "Settings"), style: .Plain, target: self.navigationController?.parentViewController, action: "toggle")
            _menuBarButton = v
        }
        return _menuBarButton
    }

}
