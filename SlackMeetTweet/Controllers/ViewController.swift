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
    
    // Fetch tweets at intervals
    delayExec(2.5) {
      self.fetchTweet()
    }
    let tweetTimer = Timer(interval: 10, repeat: true, repeatCount: nil) {
      self.fetchTweet()
    }
    tweetTimer.start()
    
    // Fetch vacancy at intervals
    let vacancyTimer = Timer(interval: 1, repeat: true, repeatCount: nil) {
      self.fetchVacancy()
    }
    vacancyTimer.start()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Data
  
  func fetchVacancy() {
    dataSync.fetchVacancy().continueWithSuccessBlock {
      (task: BFTask!) -> BFTask! in
      let vacancy = task.result as! Vacancy
      self.mainExec {
        self.vacancyFetched(vacancy)
      }
      return nil
    }
  }
  
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
      self.tweetFetched(tweet)
      return nil
    })
  }
  
  // MARK: - UI
  
  func vacancyFetched(vacancy: Vacancy) {
    switch vacancy.vacancy {
    case .vacant:
      indicatorImageView.image = UIImage(named: "ledGreen")
    case .pending:
      indicatorImageView.image = UIImage(named: "ledYellow")
    case .booked:
      indicatorImageView.image = UIImage(named: "ledRed")
    }
  }
  
  func tweetFetched(tweet: Tweet) {
    self.displayTweet(tweet)
  }
  
  func displayTweet(tweet: Tweet) {
    switch tweet.mime {
    case "text/plain":
      displayTextTweet(tweet)
    case "image/jpeg":
      displayImageTweet(tweet)
    default:
      assertionFailure("\(tweet.mime) mime type not allowed")
    }
  }
  
  func displayTextTweet(tweet: Tweet) {
    mainExec {
      self.displayContentLabel(tweet.payload)
      self.hideLoader()
      self.displayBar(tweet)
    }
  }
  
  func displayImageTweet(tweet: Tweet) {
    dataSync.downloadImage(tweet.payload).continueWithSuccessBlock {
      (task: BFTask!) -> BFTask! in
      let uiImage = task.result as! UIImage
      self.mainExec {
        self.displayImage(uiImage)
        self.hideLoader()
        self.displayBar(tweet)
      }
      return nil
    }
  }
  
  func displayImage(image: UIImage) {
    // Fade image out and in
    UIView.animateWithDuration(
      0.3,
      delay: 0,
      options: UIViewAnimationOptions.CurveEaseIn,
      animations: {
        () -> Void in
        self.contentLabel.alpha = 0
        self.imageView.alpha = 0
      },
      completion: {
        (finished) -> Void in
        self.imageView.image = image
        UIView.animateWithDuration(
          0.5,
          delay: 0,
          options: UIViewAnimationOptions.CurveEaseIn,
          animations: {
            () -> Void in
            self.imageView.alpha = 1
          },
          completion: {
            (finished) -> Void in
          }
        )
      }
    )
    
  }
  
  func displayContentLabel(text: String) {
    // Fade content out and in
    UIView.animateWithDuration(
      0.3,
      delay: 0,
      options: UIViewAnimationOptions.CurveEaseIn,
      animations: {
        () -> Void in
        self.contentLabel.alpha = 0
        self.imageView.alpha = 0
      },
      completion: {
        (finished) -> Void in
        self.contentLabel.text = text
        UIView.animateWithDuration(
          0.5,
          delay: 0,
          options: UIViewAnimationOptions.CurveEaseIn,
          animations: {
            () -> Void in
            self.contentLabel.alpha = 1
          },
          completion: {
            (finished) -> Void in
          }
        )
      }
    )
  }
  
  func displayBar(tweet: Tweet) {
    // Format sent date
    let formatter = NSDateFormatter()
    formatter.dateStyle = NSDateFormatterStyle.MediumStyle
    formatter.timeStyle = .ShortStyle
    let dateString = formatter.stringFromDate(tweet.updatedAt!)
    
    // Fade in bar and labels
    UIView.animateWithDuration(
      0.3,
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
          0.3,
          delay: 0,
          options: UIViewAnimationOptions.CurveEaseOut,
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
  
  // MARK: - Utils
  
  // Dispatch on main queue
  func mainExec(closure: ()->()) {
    dispatch_async(dispatch_get_main_queue(), closure)
  }
  
  // Dispatch on main queue after delay
  func delayExec(delay: Double, closure: ()->()) {
    dispatch_after(
      dispatch_time(
        DISPATCH_TIME_NOW,
        Int64(delay * Double(NSEC_PER_SEC))
      ),
      dispatch_get_main_queue(), closure)
  }
}