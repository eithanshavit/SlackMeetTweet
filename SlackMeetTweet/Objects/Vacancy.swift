//
//  Vacancy.swift
//  SlackMeetTweet
//
//  Created by  Eithan Shavit on 5/7/15.
//  Copyright (c) 2015 Eithan Shavit. All rights reserved.
//

import UIKit
import Parse

enum VacancyOptions: Int {
  case vacant = 0
  case pending = 1
  case booked = 2
}

class Vacancy : PFObject, PFSubclassing {
  
  @NSManaged var state: Int
  
  var vacancy: VacancyOptions {
    get {
      // Todo: validate vacany enum is within scope
      return VacancyOptions(rawValue: state)!
    }
  }
  
  override class func initialize() {
    struct Static {
      static var onceToken : dispatch_once_t = 0;
    }
    dispatch_once(&Static.onceToken) {
      self.registerSubclass()
    }
  }
  
  static func parseClassName() -> String {
    return "Vacancy"
  }
}