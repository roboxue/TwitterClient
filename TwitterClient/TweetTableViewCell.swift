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
            make.left.equalTo(profileImage.snp_right).offset(TWSpanSize)
            make.top.equalTo(usernameLabel.snp_bottom)
            make.right.lessThanOrEqualTo(self).offset(-TWSpanSize)
            make.bottom.lessThanOrEqualTo(self).offset(-TWSpanSize * 2)
       }
    }

    func initWithTweet(tweet: Tweet) {
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
}
