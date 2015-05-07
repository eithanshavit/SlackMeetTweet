//
//  Tweet.swift
//  SlackMeetTweet
//
//  Created by  Eithan Shavit on 5/7/15.
//  Copyright (c) 2015 Eithan Shavit. All rights reserved.
//

import UIKit
import Parse

class Tweet : PFObject, PFSubclassing {
  
  @NSManaged var mime: String
  @NSManaged var payload: String
  @NSManaged var slot: Int
  @NSManaged var username: String
  
  override class func initialize() {
    struct Static {
      static var onceToken : dispatch_once_t = 0;
    }
    dispatch_once(&Static.onceToken) {
      self.registerSubclass()
    }
  }
  
  static func parseClassName() -> String {
    return "Tweet"
  }
}