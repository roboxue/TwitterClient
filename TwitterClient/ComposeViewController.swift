//
//  ComposeViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftSpinner

class ComposeViewController: TWBaseViewController {
    private var _profileImage: UIImageView!
    private var _usernameLabel: UILabel!
    private var _screennameLabel: UILabel!
    private var _tweetInput: UITextView!
    private var _tweetButton: UIBarButtonItem!
    private var _wordCount: UIBarButtonItem!
    private var _replyToLabel: UILabel!
    var delegate: ComposeViewControllerDelegate?
    var inReplyTo: Tweet?
    
    private let wordLimit = 140
    
    override func addSubviews() {
        navigationItem.rightBarButtonItems = [tweetButton, wordCount]
        view.addSubview(profileImage)
        view.addSubview(usernameLabel)
        view.addSubview(screennameLabel)
        view.addSubview(tweetInput)
        view.addSubview(replyToLabel)
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
        replyToLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(profileImage.snp_bottom).offset(TWSpanSize)
            make.left.equalTo(profileImage)
        }
        tweetInput.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(replyToLabel.snp_bottom).offset(2 * TWSpanSize)
            make.left.equalTo(profileImage)
            make.right.equalTo(view).offset(-TWSpanSize * 2)
            make.bottom.equalTo(snp_bottomLayoutGuideTop)
        }
    }
    
    override func refreshUI() {
        if let user = TWApi.currentUser {
            usernameLabel.text = user.name
            if let screenname = user.screenname {
                screennameLabel.text = "@" + screenname
            }
            if let imageUrl = user.profileImageUrl {
                profileImage.af_setImageWithURL(imageUrl, filter: RoundedCornersFilter(radius: 2.0))
            }
        }
        if let inReplyTo = inReplyTo {
            replyToLabel.text = "In reply to \(inReplyTo.user!.name!)"
            tweetInput.text = "@\(inReplyTo.user!.screenname!) "
        }
        tweetInput.becomeFirstResponder()
    }
}

extension ComposeViewController {
    func didPressedTweetButton() {
        let tweet = tweetInput.text
        TWApi.updateStatus(tweet, replyTo: inReplyTo?.id) { (tweet, error) -> Void in
            if let tweet = tweet {
                self.delegate?.didComposedTweet(tweet)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        let remaining = wordLimit - textView.text.utf8.count
        wordCount.title = String(remaining)
        if remaining < 0 {
            wordCount.tintColor = UIColor.redColor()
        } else {
            wordCount.tintColor = TWSecondaryTextColor
        }
        tweetButton.enabled = !textView.text.isEmpty && remaining >= 0
    }
}

extension ComposeViewController {
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
    
    var tweetInput: UITextView {
        if _tweetInput == nil {
            let v = UITextView()
            v.font = TWTweetFont
            v.enablesReturnKeyAutomatically = true
            v.delegate = self
            _tweetInput = v
        }
        return _tweetInput
    }
    
    var wordCount: UIBarButtonItem {
        if _wordCount == nil {
            let v = UIBarButtonItem(title: String(wordLimit), style: .Plain, target: self, action: nil)
            v.tintColor = TWSecondaryTextColor
            _wordCount = v
        }
        return _wordCount
    }
    
    var tweetButton: UIBarButtonItem {
        if _tweetButton == nil {
            let v = UIBarButtonItem(title: "Tweet", style: .Plain, target: self, action: "didPressedTweetButton")
            v.enabled = false
            _tweetButton = v
        }
        return _tweetButton
    }
    
    var replyToLabel: UILabel {
        if _replyToLabel == nil {
            let v = UILabel()
            v.font = TWContentFont
            v.textColor = TWSecondaryTextColor
            _replyToLabel = v
        }
        return _replyToLabel
    }
}

protocol ComposeViewControllerDelegate {
    func didComposedTweet(tweet: Tweet)
}
