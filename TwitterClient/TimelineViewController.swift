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
    private var tweets = [Tweet]()
    private var _tableView: UITableView!
    
    override func addSubviews() {
        navigationItem.leftBarButtonItem = signOutButton
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
        TWApi.getTimeline { (tweets, _) -> Void in
            if let tweets = tweets {
                self.tweets = tweets
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
        cell.initWithTweet(tweet)
        return cell
    }
}

extension TimelineViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
    
    var tableView: UITableView {
        if _tableView == nil {
            let v = UITableView()
            v.dataSource = self
            v.delegate = self
            v.estimatedRowHeight = 120
            v.rowHeight = UITableViewAutomaticDimension
            v.tableFooterView = UIView()
            _tableView = v
        }
        return _tableView
    }
}
