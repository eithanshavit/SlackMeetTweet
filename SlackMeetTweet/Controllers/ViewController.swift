//
//  ViewController.swift
//  SlackMeetTweet
//
//  Created by  Eithan Shavit on 5/6/15.
//  Copyright (c) 2015 Eithan Shavit. All rights reserved.
//

import UIKit
import Bolts

class ViewController: UIViewController {
  
  // MARK: - State
  
  var index: Int = -1
  var dataSync = DataSync.sharedInstance
  var timer: Timer!
  
  // MARK: Outlets
  
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var indicatorImageView: UIImageView!
  @IBOutlet weak var loadingLabel: UILabel!
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    timer = Timer(interval: 15, repeat: true, repeatCount: nil) {
      self.fetchTweet()
    }
    timer.start()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Data
  
  func fetchTweet() {
    // First count tweets
    dataSync.fetchTweetCount().continueWithSuccessBlock({
      (task: BFTask!) -> BFTask! in
      let tweetCount = task.result as! Int
      self.index = (self.index + 1) % tweetCount
      return self.dataSync.fetchTweetByIndex(self.index)
    // Then fetch tweet by index
    }).continueWithSuccessBlock({
      (task: BFTask!) -> BFTask! in
      let tweet = task.result as! Tweet
      self.displayTweet(tweet)
      return nil
    })
  }
  
  // MARK: - UI
  
  func displayTweet(tweet: Tweet) {
    println("displaying tweet - \(tweet.payload)")
  }
  
}

