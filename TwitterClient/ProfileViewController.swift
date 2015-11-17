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
import SnapKit

class ProfileViewController: TWBaseViewController {
    private var _topBackgroundView: UIImageView!
    private var _profileImageView: UIButton!
    private var _nameLabel: UILabel!
    private var _backupNameLabel: UILabel!
    private var _screennameLabel: UILabel!
    private var _taglineLabel: UILabel!
    private var _tweetsCountLabel: UILabel!
    private var _followingCountLabel: UILabel!
    private var _followersCountLabel: UILabel!
    private var _tableView: UITableView!
    private var _panelView: UIView!
    private var _panelPanGR: UIPanGestureRecognizer!
    private let _imageMaxDimension = CGFloat(73)
    private let _imageMinDimension = CGFloat(48)
    private let _barheight = CGFloat(66)
    private let _statusBarHeight = CGFloat(20)
    
    var userId: Int!
    var originTintColor: UIColor!
    var originBarTintColor: UIColor!
    var tweets = [Tweet]()
    var panelTopConstaint: Constraint!
    var profileImageDimension: Constraint!
    var panelOriginY: CGFloat!

    override func initializeUI() {
        originBarTintColor = navigationController?.navigationBar.barTintColor
        originTintColor = navigationController?.navigationBar.tintColor
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.tintColor = originTintColor
        navigationController?.navigationBar.barTintColor = originBarTintColor
    }
    
    override func addSubviews() {
        view.addSubview(panelView)
        panelView.addSubview(topBackgroundView)
        panelView.addSubview(profileImageView)
        panelView.addSubview(nameLabel)
        panelView.addSubview(screennameLabel)
        panelView.addSubview(taglineLabel)
        panelView.addSubview(tweetsCountLabel)
        panelView.addSubview(followingCountLabel)
        panelView.addSubview(followersCountLabel)
        panelView.addSubview(tableView)
        panelView.addGestureRecognizer(panelPanGR)
        view.addSubview(navigationController!.navigationBar)
    }
    
    override func addLayouts() {
        panelView.snp_makeConstraints { (make) -> Void in
            self.panelTopConstaint = make.top.equalTo(view).constraint
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        topBackgroundView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(panelView).priorityLow()
            make.left.equalTo(panelView)
            make.right.equalTo(panelView)
            make.height.equalTo(panelView.snp_width).dividedBy(3)
            make.top.greaterThanOrEqualTo(view).offset(-_barheight)
        }
        profileImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(panelView.snp_left).offset(_imageMaxDimension / 2 + TWSpanSize * 2)
            make.centerY.equalTo(panelView.snp_top).offset(130 + _imageMaxDimension / 2 - TWSpanSize * 4)
            self.profileImageDimension = make.width.equalTo(_imageMaxDimension).constraint
            make.height.equalTo(profileImageView.snp_width)
        }
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(profileImageView.snp_centerY).offset(_imageMaxDimension / 2 + TWSpanSize * 2)
            make.left.equalTo(panelView).offset(TWSpanSize * 2)
        }
        
        screennameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp_bottom).offset(TWSpanSize)
            make.left.equalTo(nameLabel)
        }
        taglineLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(screennameLabel.snp_bottom)
            make.left.equalTo(nameLabel)
            make.right.lessThanOrEqualTo(panelView).offset(-TWSpanSize)
        }
        tweetsCountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(taglineLabel.snp_bottom).offset(TWSpanSize)
            make.left.equalTo(nameLabel)
        }
        followingCountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(tweetsCountLabel)
            make.left.equalTo(tweetsCountLabel.snp_right).offset(TWSpanSize * 4)
        }
        followersCountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(tweetsCountLabel)
            make.left.equalTo(followingCountLabel.snp_right).offset(TWSpanSize * 4)
        }
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(tweetsCountLabel.snp_bottom).offset(TWSpanSize * 2)
            make.left.equalTo(panelView)
            make.right.equalTo(panelView)
            make.bottom.equalTo(panelView)
        }
    }
    
    override func refreshUI() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        TWApi.showUser(userId) { (user, error) -> Void in
            if let user = user {
                if let tweet = user.tweet {
                    self.tweets = [tweet]
                }
                self.tableView.reloadData()
                self.tableView.snp_updateConstraints(closure: { (make) -> Void in
                    make.height.equalTo(self.tableView.contentSize.height)
                })
                if let backgroundColor = user.profileBackgroundColor {
                    self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#" + backgroundColor)
                    self.topBackgroundView.backgroundColor = UIColor(rgba: "#" + backgroundColor)
                } else {
                    self.navigationController?.navigationBar.barTintColor = TWBlue
                    self.topBackgroundView.backgroundColor = TWBlue
                }
                self.navigationController?.navigationBar.tintColor = TWBackgroundColor
                if let bannerImageUrl = user.profileBannerUrl {
                    self.topBackgroundView.af_setImageWithURL(bannerImageUrl)
                }
                TWApi.fetchImage(user.profileImageUrl!, completion: { (image, error) -> Void in
                    self.profileImageView.setImage(image?.af_imageScaledToSize(CGSizeMake(73, 73)).af_imageWithRoundedCornerRadius(3), forState: .Normal)
                })
                self.nameLabel.text = user.name
                self.backupNameLabel.text = user.name
                self.screennameLabel.text = "@" + user.screenname!
                self.taglineLabel.text = user.tagline
                self.tweetsCountLabel.attributedText = self.composeAttributeString(String(user.statusesCount!), right: "TWEET")
                self.followingCountLabel.attributedText = self.composeAttributeString(String(user.friendsCount!), right: "FOLLOWING")
                self.followersCountLabel.attributedText = self.composeAttributeString(String(user.statusesCount!), right: "FOLLOWER")
            }
        }
    }
}

extension ProfileViewController {
    func panelDidPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        switch sender.state {
        case .Began:
            panelOriginY = panelView.frame.origin.y
        case .Changed:
            let newY = translation.y + panelOriginY
            if newY < 0 {
                panelTopConstaint.updateOffset(newY)
                if _imageMaxDimension + newY > _imageMinDimension {
                    profileImageDimension.updateOffset(_imageMaxDimension + newY)
                }
            }
            if newY < -_barheight {
                panelView.addSubview(topBackgroundView)
            } else {
                panelView.addSubview(profileImageView)
            }
            let nameLabelY = nameLabel.convertPoint(CGPointZero, toView: UIApplication.sharedApplication().keyWindow).y
            let topBackgroundViewY = topBackgroundView.convertPoint(CGPointZero, toView: UIApplication.sharedApplication().keyWindow).y + topBackgroundView.frame.height
            debugPrint(nameLabelY)
            if nameLabelY < topBackgroundViewY {
                let diff = topBackgroundViewY - nameLabelY
                topBackgroundView.addSubview(backupNameLabel)
                backupNameLabel.snp_remakeConstraints(closure: { (make) -> Void in
                    make.centerX.equalTo(topBackgroundView)
                    if nameLabelY > _statusBarHeight + TWSpanSize {
                        make.top.equalTo(topBackgroundView.snp_bottom).offset(-diff).priorityLow()
                    } else {
                        make.top.equalTo(view).offset(_statusBarHeight + TWSpanSize)
                    }
                })
            } else {
                backupNameLabel.removeFromSuperview()
            }
        default:
            break
        }
    }
    
    private func composeAttributeString(left: String, right: String) -> NSAttributedString {
        let countText = NSMutableAttributedString(string: left, attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: TWContentFont])
        countText.appendAttributedString(NSAttributedString(string: " " + right, attributes: [NSForegroundColorAttributeName: TWSecondaryTextColor, NSFontAttributeName: TWContentFont]))
        return countText
    }
}

extension ProfileViewController: TweetDelegate {
    func reply(tweet: Tweet) {
        let replyScreen = ComposeViewController()
        replyScreen.inReplyTo = tweet
        navigationController?.pushViewController(replyScreen, animated: true)
    }
    
    func fav(tweet: Tweet) {
        TWApi.favorite(!(tweet.favorited ?? true), id: tweet.id!) { (updatedTweet, error) -> Void in
            if let updatedTweet = updatedTweet {
                tweet.dictionary = updatedTweet.dictionary
                self.tableView.reloadData()
            }
        }
    }
    
    func retweet(tweet: Tweet) {
        TWApi.retweet(tweet.id!) { (updatedTweet, error) -> Void in
            if let updatedTweet = updatedTweet {
                tweet.dictionary = updatedTweet.dictionary
                self.tableView.reloadData()
            }
        }
    }
    
    func visit(userId: Int) {
        let userScreen = ProfileViewController()
        userScreen.userId = userId
        navigationController?.pushViewController(userScreen, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "TweetCell"
        let cell: TweetTableViewCell
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? TweetTableViewCell {
            cell = reuseCell
        } else {
            cell = TweetTableViewCell(style: .Default, reuseIdentifier: reuseId)
        }
        let tweet = tweets[indexPath.row]
        cell.delegate = self
        cell.initWithTweet(tweet)
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let statusVC = TweetViewController()
        statusVC.tweet = tweets[indexPath.row]
        navigationController?.pushViewController(statusVC, animated: true)
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
    
    var profileImageView: UIButton {
        if _profileImageView == nil {
            let v = UIButton(type: .Custom)
            v.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3)
            v.contentVerticalAlignment = .Fill
            v.contentHorizontalAlignment = .Fill
            v.backgroundColor = TWBackgroundColor
            v.layer.cornerRadius = 3
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
    
    var backupNameLabel: UILabel {
        if _backupNameLabel == nil {
            let v = UILabel()
            v.font = TWContentFontBold
            v.textColor = TWBackgroundColor
            _backupNameLabel = v
        }
        return _backupNameLabel
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
            v.font = TWContentFontBold
            v.numberOfLines = 0
            v.lineBreakMode = .ByWordWrapping
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
    
    var tableView: UITableView {
        if _tableView == nil {
            let v = UITableView()
            v.dataSource = self
            v.delegate = self
            v.estimatedRowHeight = 120
            v.rowHeight = UITableViewAutomaticDimension
            v.tableFooterView = UIView()
            v.scrollEnabled = false
            _tableView = v
        }
        return _tableView
    }
    
    var panelView: UIView {
        if _panelView == nil {
            let v = UIView()
            _panelView = v
        }
        return _panelView
    }
    
    var panelPanGR: UIPanGestureRecognizer {
        if _panelPanGR == nil {
            let gr = UIPanGestureRecognizer(target: self, action: "panelDidPan:")
            _panelPanGR = gr
        }
        return _panelPanGR
    }
}
