//
//  ServicesViewController.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/6/15.
//  Copyright © 2015 Ossus. All rights reserved.
//

import Cocoa
import Quartz


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
}

