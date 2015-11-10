//
//  TweetViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/9/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit
import AlamofireImage

class TweetViewController: TWBaseViewController {
    var tweet: Tweet!
    private var _profileImage: UIImageView!
    private var _usernameLabel: UILabel!
    private var _screennameLabel: UILabel!
    private var _tweetView: UILabel!
    private var _timeLabel: UILabel!
    private var _toolbar: UIToolbar!
    private var _replyButton: UIBarButtonItem!
    private var _retweetButton: UIBarButtonItem!
    private var _favButton: UIBarButtonItem!
    private var _retweetCountLabel: UILabel!
    private var _favCountLabel: UILabel!
    private var _saperator: UIView!


    override func initializeUI() {
        view.backgroundColor = TWBackgroundColor
    }
    
    override func addSubviews() {
        view.addSubview(profileImage)
        view.addSubview(usernameLabel)
        view.addSubview(screennameLabel)
        view.addSubview(tweetView)
        view.addSubview(timeLabel)
        view.addSubview(saperator)
        view.addSubview(retweetCountLabel)
        view.addSubview(favCountLabel)
        view.addSubview(toolbar)
    }
    
    override func addLayouts() {
        profileImage.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(snp_topLayoutGuideBottom).offset(TWSpanSize * 2)
            make.left.equalTo(view).offset(TWSpanSize * 2)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        usernameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(profileImage)
            make.left.equalTo(profileImage.snp_right).offset(TWSpanSize)
        }
        screennameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(usernameLabel.snp_bottom).offset(TWSpanSize)
            make.left.equalTo(profileImage.snp_right).offset(TWSpanSize)
        }
        tweetView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(profileImage.snp_bottom).offset(TWSpanSize * 2)
            make.left.equalTo(profileImage)
            make.right.equalTo(view).offset(-TWSpanSize * 2)
        }
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(tweetView.snp_bottom).offset(TWSpanSize)
            make.left.equalTo(tweetView)
        }
        saperator.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(0.5)
            make.top.equalTo(timeLabel.snp_bottom).offset(TWSpanSize * 2)
            make.left.equalTo(view).offset(TWSpanSize * 2)
            make.right.equalTo(view).offset(-TWSpanSize * 2)
        }
        retweetCountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(saperator.snp_bottom).offset(TWSpanSize * 2)
            make.left.equalTo(tweetView)
        }
        favCountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(saperator.snp_bottom).offset(TWSpanSize * 2)
            make.left.equalTo(retweetCountLabel.snp_right).offset(TWSpanSize)
        }
        toolbar.snp_makeConstraints { (make) -> Void in
            make.top.greaterThanOrEqualTo(retweetCountLabel.snp_bottom).offset(TWSpanSize * 2)
            make.top.greaterThanOrEqualTo(favCountLabel.snp_bottom).offset(TWSpanSize)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
    }
    
    override func refreshUI() {
        if let user = tweet.user {
            usernameLabel.text = user.name
            if let screenname = user.screenname {
                screennameLabel.text = "@" + screenname
            }
            if let imageUrl = user.profileImageUrl {
                profileImage.af_setImageWithURL(imageUrl, filter: RoundedCornersFilter(radius: 2.0))
            }
            retweetButton.enabled = TWApi.currentUser?.id != user.id
        }
        tweetView.text = tweet.text
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        if let createdAt = tweet.createdAt {
            timeLabel.text = formatter.stringFromDate(createdAt)
        }
        if let fav = tweet.favorited where fav == true {
            favButton.tintColor = TWHighlightColor
        } else {
            favButton.tintColor = TWSecondaryTextColor
        }
        
        if let retweeted = tweet.retweeted where retweeted == true {
            retweetButton.tintColor = TWRetweetedColor
        } else {
            retweetButton.tintColor = TWSecondaryTextColor
        }
        
        if let retweetCount = tweet.retweetCount where retweetCount > 0 {
            let countText = NSMutableAttributedString(string: String(retweetCount), attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: TWContentFont])
            countText.appendAttributedString(NSAttributedString(string: retweetCount > 1 ? " RETWEETS" : " RETWEET", attributes: [NSForegroundColorAttributeName: TWSecondaryTextColor, NSFontAttributeName: TWContentFont]))
            retweetCountLabel.attributedText = countText
        } else {
            retweetCountLabel.attributedText = nil
        }

        if let favCount = tweet.favouritesCount where favCount > 0 {
            let countText = NSMutableAttributedString(string: String(favCount), attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: TWContentFont])
            countText.appendAttributedString(NSAttributedString(string: favCount > 1 ? " LIKES" : " LIKE", attributes: [NSForegroundColorAttributeName: TWSecondaryTextColor, NSFontAttributeName: TWContentFont]))
            favCountLabel.attributedText = countText
        } else {
            favCountLabel.attributedText = nil
        }
    }
}

extension TweetViewController {
    func didPressedReplyButton() {
        let replyScreen = ComposeViewController()
        replyScreen.inReplyTo = tweet
        navigationController?.pushViewController(replyScreen, animated: true)
    }
    
    func didPressedFavButton() {
        TWApi.favorite(!(tweet.favorited ?? true), id: tweet.id!) { (updatedTweet, error) -> Void in
            if let updatedTweet = updatedTweet {
                self.tweet = updatedTweet
                self.refreshUI()
            }
        }
    }
    
    func didPressedRetweetButton() {
        TWApi.retweet(tweet.id!) { (updatedTweet, error) -> Void in
            if let updatedTweet = updatedTweet {
                self.tweet = updatedTweet
                self.refreshUI()
            }
        }
    }
}

extension TweetViewController {
    var profileImage: UIImageView {
        if _profileImage == nil {
            let v = UIImageView()
            _profileImage = v
        }
        return _profileImage
    }
    
    var usernameLabel: UILabel {
        if _usernameLabel == nil {
            let v = UILabel()
            v.font = TWContentFontBold
            _usernameLabel = v
        }
        return _usernameLabel
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
    
    var tweetView: UILabel {
        if _tweetView == nil {
            let v = UILabel()
            v.font = TWTweetFontLarge
            v.lineBreakMode = .ByWordWrapping
            v.numberOfLines = 0
            _tweetView = v
        }
        return _tweetView
    }
    
    var timeLabel: UILabel {
        if _timeLabel == nil {
            let v = UILabel()
            v.font = TWContentFont
            v.textColor = TWSecondaryTextColor
            _timeLabel = v
        }
        return _timeLabel
    }
    
    var toolbar: UIToolbar {
        if _toolbar == nil {
            let v = UIToolbar()
            let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
            let buttons = [space, replyButton, space, retweetButton, space, favButton, space]
            v.setItems(buttons, animated: true)
            v.barTintColor = TWBackgroundColor
            v.tintColor = TWSecondaryTextColor
            _toolbar = v
        }
        return _toolbar
    }
    
    var replyButton: UIBarButtonItem {
        if _replyButton == nil {
            let v = UIBarButtonItem(image: UIImage(named: "si-glyph-arrow-backward")!.af_imageScaledToSize(CGSizeMake(15, 15)), style: .Plain, target: self, action: "didPressedReplyButton")
            _replyButton = v
        }
        return _replyButton
    }

    var retweetButton: UIBarButtonItem {
        if _retweetButton == nil {
            let v = UIBarButtonItem(image: UIImage(named: "si-glyph-arrow-change")!.af_imageScaledToSize(CGSizeMake(15, 15)), style: .Plain, target: self, action: "didPressedRetweetButton")
            _retweetButton = v
        }
        return _retweetButton
    }

    var favButton: UIBarButtonItem {
        if _favButton == nil {
            let v = UIBarButtonItem(image: UIImage(named: "si-glyph-bookmark")!.af_imageScaledToSize(CGSizeMake(15, 15)), style: .Plain, target: self, action: "didPressedFavButton")
            _favButton = v
        }
        return _favButton
    }

    var retweetCountLabel: UILabel {
        if _retweetCountLabel == nil {
            let v = UILabel()
            v.textColor = TWSecondaryTextColor
            v.font = TWContentFont
            _retweetCountLabel = v
        }
        return _retweetCountLabel
    }
    
    var favCountLabel: UILabel {
        if _favCountLabel == nil {
            let v = UILabel()
            v.textColor = TWSecondaryTextColor
            v.font = TWContentFont
            _favCountLabel = v
        }
        return _favCountLabel
    }
    
    var saperator: UIView {
        if _saperator == nil {
            let v = UIView()
            v.backgroundColor = TWSecondaryTextColor
            _saperator = v
        }
        return _saperator
    }
}
