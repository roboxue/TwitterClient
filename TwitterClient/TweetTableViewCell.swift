//
//  TweetTableViewCell.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit
import AlamofireImage

class TweetTableViewCell: UITableViewCell {
    private var _profileImage: UIImageView!
    private var _usernameLabel: UILabel!
    private var _screenameLabel: UILabel!
    private var _tweetLabel: UILabel!
    private var _timeLabel: UILabel!
    private var _replyButton: UIButton!
    private var _retweetButton: UIButton!
    private var _favButton: UIButton!
    var tweet: Tweet!
    var delegate: TweetDelegate!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        addLayouts()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addSubviews() {
        addSubview(profileImage)
        addSubview(usernameLabel)
        addSubview(screennameLabel)
        addSubview(tweetLabel)
        addSubview(timeLabel)
        addSubview(replyButton)
        addSubview(favButton)
        addSubview(retweetButton)
    }
    
    func addLayouts() {
        profileImage.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(TWSpanSize * 2)
            make.top.equalTo(self).offset(TWSpanSize)
            make.width.equalTo(48)
            make.height.equalTo(48)
            make.bottom.lessThanOrEqualTo(self).offset(-TWSpanSize * 2)
        }
        usernameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(profileImage.snp_right).offset(TWSpanSize)
            make.top.equalTo(profileImage)
        }
        screennameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(usernameLabel.snp_right).offset(TWSpanSize)
            make.bottom.equalTo(usernameLabel)
        }
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(self).offset(-TWSpanSize)
            make.bottom.equalTo(usernameLabel)
            make.left.greaterThanOrEqualTo(screennameLabel.snp_right).offset(TWSpanSize)
        }
        timeLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        tweetLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(usernameLabel)
            make.top.equalTo(usernameLabel.snp_bottom)
            make.right.lessThanOrEqualTo(self).offset(-TWSpanSize)
        }
        replyButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(usernameLabel)
            make.top.equalTo(tweetLabel.snp_bottom)
            make.bottom.lessThanOrEqualTo(self).offset(-TWSpanSize)
        }
        retweetButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(replyButton.snp_right).offset(40)
            make.top.equalTo(replyButton)
        }
        favButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(retweetButton.snp_right).offset(40)
            make.top.equalTo(replyButton)
        }
    }

    func initWithTweet(tweet: Tweet) {
        self.tweet = tweet
        if let profileImageUrl = tweet.user?.profileImageUrl {
            profileImage.af_setImageWithURL(profileImageUrl, filter: RoundedCornersFilter(radius: 2.0))
        }
        usernameLabel.text = tweet.user?.name
        if let screenname = tweet.user?.screenname {
            screennameLabel.text = "@" + screenname
        }
        tweetLabel.text = tweet.text
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        timeLabel.text = tweet.createdAt?.timeAgo(formatter)
        if let retweeted = tweet.retweeted where retweeted == true {
            retweetButton.tintColor = TWRetweetedColor
        } else {
            retweetButton.tintColor = TWSecondaryTextColor
        }
        if let favorited = tweet.favorited where favorited == true {
            favButton.tintColor = TWHighlightColor
        } else {
            favButton.tintColor = TWSecondaryTextColor
        }
    }
}

extension TweetTableViewCell {
    func didPressedReplyButton() {
        delegate.reply(tweet)
    }
    
    func didPressedFavButton() {
        delegate.fav(tweet)
    }
    
    func didPressedRetweetButton() {
        delegate.retweet(tweet)
    }
}

extension TweetTableViewCell {
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
        if _screenameLabel == nil {
            let v = UILabel()
            v.font = TWContentFont
            v.textColor = TWSecondaryTextColor
            _screenameLabel = v
        }
        return _screenameLabel
    }
    
    var tweetLabel: UILabel {
        if _tweetLabel == nil {
            let v = UILabel()
            v.numberOfLines = 0
            v.lineBreakMode = .ByWordWrapping
            v.font = TWTweetFont
            _tweetLabel = v
        }
        return _tweetLabel
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
    
    var replyButton: UIButton {
        if _replyButton == nil {
            let v = UIButton(type: .System)
            v.setImage(UIImage(named: "si-glyph-arrow-backward")!.af_imageScaledToSize(CGSizeMake(15, 15)), forState: .Normal)
            v.addTarget(self, action: "didPressedReplyButton", forControlEvents: .TouchUpInside)
            v.tintColor = TWSecondaryTextColor
            _replyButton = v
        }
        return _replyButton
    }
    
    var retweetButton: UIButton {
        if _retweetButton == nil {
            let v = UIButton(type: .System)
            v.setImage(UIImage(named: "si-glyph-arrow-change")!.af_imageScaledToSize(CGSizeMake(15, 15)), forState: .Normal)
            v.addTarget(self, action: "didPressedRetweetButton", forControlEvents: .TouchUpInside)
            _retweetButton = v
        }
        return _retweetButton
    }
    
    var favButton: UIButton {
        if _favButton == nil {
            let v = UIButton(type: .System)
            v.setImage(UIImage(named: "si-glyph-bookmark")!.af_imageScaledToSize(CGSizeMake(15, 15)), forState: .Normal)
            v.addTarget(self, action: "didPressedFavButton", forControlEvents: .TouchUpInside)
            _favButton = v
        }
        return _favButton
    }
}
