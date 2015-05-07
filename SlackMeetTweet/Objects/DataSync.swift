//
//  DataSync.swift
//  selek
//
//  Created by  Eithan Shavit on 2/11/15.
//  Copyright (c) 2015 Eithan Shavit. All rights reserved.
//
//  The DataSync singleton is responsible for syncing local data with the cloud

import UIKit
import Parse
import Bolts

class DataSync: NSObject {
  
  // MARK: - Singleton
  
  class var sharedInstance: DataSync {
    struct Singleton {
      static let instance = DataSync()
    }
    return Singleton.instance
  }
  
  // MARK: - Fetch Data  
  
  func fetchPointer() -> BFTask {
    let query = Pointer.query()!
    return query.getFirstObjectInBackground().continueWithBlock {
      (task: BFTask!) -> BFTask! in
      switch task {
        // Cancelled
      case let task where task.cancelled:
        self.errorSyncFail(NSError(domain: "com.eithanshavit.SlackMeetTweet", code: 100, userInfo: task.error.userInfo))
        // Error
      case let task where task.error != nil:
        self.errorSyncFail(NSError(domain: "com.eithanshavit.SlackMeetTweet", code: 101, userInfo: task.error.userInfo))
        // Success
      default:
        let pointer = task.result as! Pointer
        return BFTask(result: pointer)
      }
      return nil
    }
  }
  
  func fetchTweetCount() -> BFTask {
    let query = Tweet.query()!
    return query.countObjectsInBackground().continueWithBlock {
      (task: BFTask!) -> BFTask! in
      switch task {
        // Cancelled
      case let task where task.cancelled:
        self.errorSyncFail(NSError(domain: "com.eithanshavit.SlackMeetTweet", code: 100, userInfo: task.error.userInfo))
        // Error
      case let task where task.error != nil:
        self.errorSyncFail(NSError(domain: "com.eithanshavit.SlackMeetTweet", code: 101, userInfo: task.error.userInfo))
        // Success
      default:
        let count = task.result as! Int
        return BFTask(result: count)
      }
      return nil
    }
  }
  
  func fetchTweetByIndex(index: Int) -> BFTask {
    let query = Tweet.query()!
    query.orderByAscending("slot")
    query.skip = index
    return query.getFirstObjectInBackground().continueWithBlock {
      (task: BFTask!) -> BFTask! in
      switch task {
        // Cancelled
      case let task where task.cancelled:
        self.errorSyncFail(NSError(domain: "com.eithanshavit.SlackMeetTweet", code: 100, userInfo: task.error.userInfo))
        // Error
      case let task where task.error != nil:
        self.errorSyncFail(NSError(domain: "com.eithanshavit.SlackMeetTweet", code: 101, userInfo: task.error.userInfo))
        // Success
      default:
        if let tweet = task.result as? Tweet {
          return BFTask(result: tweet)
        }
        return BFTask(result: nil)
      }
      return nil
    }
    
  }
  
  // MARK: - Downloads
  
  func downloadImage(url: String) -> BFTask {
    var task = BFTaskCompletionSource()
    let url = NSURL(string: url)!
    let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(url) {
      (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
      if (error != nil) {
        task.setError(error)
      }
      else {
        let uiImage = UIImage(data: NSData(contentsOfURL: location)!)
        task.setResult(uiImage)
      }
    }
    downloadTask.resume()
    return task.task
  }
  
  // MARK: - Error handling
  
  func errorSyncFail(error: NSError) {
    assertionFailure(error.description)
  }
  
}
