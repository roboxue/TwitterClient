//
//  TimelineViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit

class TimelineViewController: TWBaseViewController {
    private var _signOutButton: UIBarButtonItem!
    private var _composeButton: UIBarButtonItem!
    private var tweets = Array<Tweet>()
    private var highestId: Int? {
        return tweets.isEmpty ? nil : tweets.flatMap({ (tweet) -> Int? in
            return tweet.id
        }).maxElement()
    }
    private var _tableView: UITableView!
    private var _refreshControl: UIRefreshControl!
    
    override func addSubviews() {
        navigationItem.leftBarButtonItem = signOutButton
        navigationItem.rightBarButtonItem = composeButton
        view.addSubview(tableView)
    }
    
    override func addLayouts() {
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.bottom.equalTo(snp_bottomLayoutGuideTop)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
    }
    
    override func refreshUI() {
        TWApi.getTimeline(highestId) { (tweets, _) -> Void in
            if let tweets = tweets {
                self.refreshControl.endRefreshing()
                self.tweets = Set(self.tweets).union(tweets).sort({ (left, right) -> Bool in
                    return left.id! > right.id!
                })
                debugPrint("got \(tweets.count) tweets")
                self.tableView.reloadData()
            }
        }
    }
    
    override func initializeUI() {
        title = "Home"
        automaticallyAdjustsScrollViewInsets = false
    }
}

extension TimelineViewController {
    func didPressedSignoutButton() {
        TWApi.logout()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didPressedComposeButton() {
        navigationController?.pushViewController(ComposeViewController(), animated: true)
    }
}

extension TimelineViewController: TweetDelegate {
    func reply(tweet: Tweet) {
        let replyScreen = ComposeViewController()
        replyScreen.inReplyTo = tweet
        navigationController?.pushViewController(replyScreen, animated: true)
    }
    
    func fav(tweet: Tweet) {
        TWApi.favorite(!(tweet.favorited ?? true), id: tweet.id!) { (updatedTweet, error) -> Void in
            if let updatedTweet = updatedTweet {
                tweet.favorited = updatedTweet.favorited
                self.refreshUI()
            }
        }
    }
    
    func retweet(tweet: Tweet) {
        TWApi.retweet(tweet.id!) { (updatedTweet, error) -> Void in
            if let updatedTweet = updatedTweet {
                tweet.retweeted = updatedTweet.retweeted
                self.refreshUI()
            }
        }
    }
}


extension TimelineViewController: UITableViewDataSource {
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

extension TimelineViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let statusVC = TweetViewController()
        statusVC.tweet = tweets[indexPath.row]
        navigationController?.pushViewController(statusVC, animated: true)
    }
}

extension TimelineViewController {
    var signOutButton: UIBarButtonItem {
        if _signOutButton == nil {
            let v = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action: "didPressedSignoutButton")
            _signOutButton = v
        }
        return _signOutButton
    }
    
    var composeButton: UIBarButtonItem {
        if _composeButton == nil {
            let v = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "didPressedComposeButton")
            _composeButton = v
        }
        return _composeButton
    }
    
    var tableView: UITableView {
        if _tableView == nil {
            let v = UITableView()
            v.dataSource = self
            v.delegate = self
            v.estimatedRowHeight = 120
            v.rowHeight = UITableViewAutomaticDimension
            v.tableFooterView = UIView()
            v.addSubview(refreshControl)
            _tableView = v
        }
        return _tableView
    }
    
    var refreshControl: UIRefreshControl {
        if _refreshControl == nil {
            let v = UIRefreshControl()
            v.addTarget(self, action: "refreshUI", forControlEvents: .ValueChanged)
            _refreshControl = v
        }
        return _refreshControl
    }
}
