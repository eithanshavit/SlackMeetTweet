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
  
  var index: Int = 0
  
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
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Data
  
  func fetchTweet() {
    DataSync.sharedInstance.fetchPointer().continueWithSuccessBlock {
      (task: BFTask!) -> BFTask! in
      let pointer = task.result as! Pointer
      
      return nil
    }
  }
  
}

