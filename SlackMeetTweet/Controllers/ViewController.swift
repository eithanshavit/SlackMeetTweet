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
  
  @IBOutlet weak var barView: UIView!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var indicatorImageView: UIImageView!
  @IBOutlet weak var loadingLabel: UILabel!
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchTweet()
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
    mainExec {
      self.hideLoader()
      self.displayBar(tweet)
    }
  }
  
  func displayBar(tweet: Tweet) {
    // Format sent date
    let formatter = NSDateFormatter()
    formatter.dateStyle = NSDateFormatterStyle.MediumStyle
    formatter.timeStyle = .ShortStyle
    let dateString = formatter.stringFromDate(tweet.updatedAt!)
    
    UIView.animateWithDuration(
      0.1,
      delay: 0,
      options: UIViewAnimationOptions.CurveEaseIn,
      animations: {
        () -> Void in
        self.barView.alpha = 1
        self.userLabel.alpha = 0
        self.dateLabel.alpha = 0
      },
      completion: {
        (finished) -> Void in
        self.userLabel.text = "@" + tweet.username
        self.dateLabel.text = "on " + dateString
        UIView.animateWithDuration(
          0.1,
          delay: 0,
          options: UIViewAnimationOptions.CurveEaseIn,
          animations: {
            () -> Void in
            self.userLabel.alpha = 1
            self.dateLabel.alpha = 1
          },
          completion: {
            (finished) -> Void in
          }
        )
      }
    )
  }
  
  func hideLoader() {
    UIView.animateWithDuration(
      0.1,
      delay: 0,
      options: UIViewAnimationOptions.CurveEaseIn,
      animations: {
        () -> Void in
        self.loadingLabel.alpha = 0
      },
      completion: {
        (finished) -> Void in
      }
    )
  }
  
  func mainExec(closure: ()->()) {
    dispatch_async(dispatch_get_main_queue(), closure)
  }
  
}

