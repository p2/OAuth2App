//
//  ServicesViewController.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/6/15.
//  Copyright © 2015 Ossus. All rights reserved.
//

import Cocoa
import Quartz
import OAuth2

enum ServiceError: ErrorType {
	case NoViewController
	case IncorrectViewControllerClass
}


class ServicesViewController: NSViewController {
	
	var openController: NSWindowController?
	
	func openViewControllerWithLoader(loader: DataLoader, sender: NSButton?) throws {
		if let wc = storyboard?.instantiateControllerWithIdentifier("SingleService") as? NSWindowController {
			if let vc = wc.contentViewController as? ViewController {
				vc.loader = loader
				
				wc.showWindow(sender)
				openController = wc
				return
			}
			throw ServiceError.IncorrectViewControllerClass
		}
		throw ServiceError.NoViewController
	}
	
	@IBAction func openGitHub(sender: NSButton?) {
		try! openViewControllerWithLoader(GitHubLoader(), sender: sender)
	}
	
	@IBAction func openBitBucket(sender: NSButton?) {
		try! openViewControllerWithLoader(BitBucketLoader(), sender: sender)
	}
	
	@IBAction func openReddit(sender: NSButton?) {
		try! openViewControllerWithLoader(RedditLoader(), sender: sender)
	}
	
	@IBAction func openGoogle(sender: NSButton?) {
		try! openViewControllerWithLoader(GoogleLoader(), sender: sender)
	}
  
  // MARK: - Logging Level
  @IBOutlet var logLevelLabel: NSTextField?
  
  @IBAction func logLevelChange( sender: NSSlider ) {
    let newValue = Int( sender.doubleValue )
    var newLabel = "Default"
    if ( newValue == 0 ) {
      OAuth2Base.logger = nil
    } else {
      let newLevel = newValue == 3 ? e2LoggerLevel.trace :
                     newValue == 1 ? e2LoggerLevel.info  : e2LoggerLevel.debug
      newLabel = newLevel.stringValue()
      OAuth2Base.logger = e2LoggerPrint(name: "App Defined", level: newLevel )
    }
    self.logLevelLabel?.stringValue = newLabel
  }
  
}

