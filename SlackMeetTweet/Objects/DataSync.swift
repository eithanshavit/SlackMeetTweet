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
  
  // MARK: - Fetch
  
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
  
  func fetchTweetBySlot(slot: Int) -> BFTask {
    let query = Tweet.query()!
    query.whereKey("slot", equalTo: slot)
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
        let tweet = task.result as! Tweet
        return BFTask(result: tweet)
      }
      return nil
    }
    
  }
  
  
  
  /*
  func refreshChatGroupsForUser(user: SLKUser, dataStack: SLKDataStack) -> BFTask {
    if DebugOffline {
      return BFTask(result: nil)
    }
    
    // Fetch all chat groups
    return fetchChatGroupsForUser(user).continueWithBlock {
      (task: BFTask!) -> BFTask! in
      switch task {
      // Cancelled
      case let task where task.cancelled:
        self.errorSyncFail(selekError(201, nil))
      // Error
      case let task where task.error != nil:
        self.errorSyncFail(selekError(202, task.error.userInfo))
      // Success
      default:
        let cloudChatGroups = task.result as! [PFObject]
        // Sync with local store
        self.syncChatGroupsForUser(cloudChatGroups: cloudChatGroups, user: user, dataStack: dataStack)
      }
      return nil
    }
  }
*/
  
  // MARK: - Error handling
  
  func errorSyncFail(error: NSError) {
    assertionFailure(error.description)
  }
  
}
