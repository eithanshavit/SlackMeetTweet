//
//  Timer.swift
//  Selek
//
//  Created by  Eithan Shavit on 12/13/14.
//  Copyright (c) 2014 Eithan Shavit. All rights reserved.
//

import Foundation

// A utility class to provide a simple interval timer with block code execution
class Timer: NSObject {
  
  var timer = NSTimer()
  let action: (() -> ())
  let repeat: Bool
  var repeatForever = true
  let repeatCount: Int?
  let interval: Float
  var iterationsLeft: Int!
  
  // repeatCount - Number of times the timer fires. Pass nil to repeat forever
  init(interval: Float, repeat: Bool, repeatCount: Int?, action: ()->()) {
    self.interval = interval
    self.repeat = repeat
    self.action = action
    self.repeatCount = repeatCount
    super.init()
  }
  
  func start() {
    if let repeatCount = repeatCount {
      iterationsLeft = repeatCount
      assert(repeat && iterationsLeft > 0, "repeatCount must be greater than zero")
      repeatForever = false
    }
    self.timer = NSTimer.scheduledTimerWithTimeInterval(
      NSTimeInterval(interval),
      target: self,
      selector: Selector("tick"),
      userInfo: nil,
      repeats: repeat)
  }
  
  func stop() {
    timer.invalidate()
  }
  
  func reset() {
    stop()
    start()
  }
  
  func tick() {
    action()
    if repeat && !repeatForever {
      iterationsLeft = iterationsLeft - 1
      if iterationsLeft <= 0 {
        stop()
      }
    }
  }
  
  deinit {
    timer.invalidate()
  }
}