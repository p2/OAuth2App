//
//  ServicesViewController.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/6/15.
//  Copyright © 2015 Ossus. All rights reserved.
//

import Cocoa
import Quartz


enum ServiceError: ErrorProtocol {
	case noViewController
	case incorrectViewControllerClass
}


class ServicesViewController: NSViewController {
	
	var openController: NSWindowController?
	
	func openViewControllerWithLoader(_ loader: DataLoader, sender: NSButton?) throws {
		if let wc = storyboard?.instantiateController(withIdentifier: "SingleService") as? NSWindowController {
			if let vc = wc.contentViewController as? ViewController {
				vc.loader = loader
				
				wc.showWindow(sender)
				openController = wc
				return
			}
			throw ServiceError.incorrectViewControllerClass
		}
		throw ServiceError.noViewController
	}
	
	@IBAction func openGitHub(_ sender: NSButton?) {
		try! openViewControllerWithLoader(GitHubLoader(), sender: sender)
	}
	
	@IBAction func openBitBucket(_ sender: NSButton?) {
		try! openViewControllerWithLoader(BitBucketLoader(), sender: sender)
	}
	
	@IBAction func openReddit(_ sender: NSButton?) {
		try! openViewControllerWithLoader(RedditLoader(), sender: sender)
	}
	
	@IBAction func openGoogle(_ sender: NSButton?) {
		try! openViewControllerWithLoader(GoogleLoader(), sender: sender)
	}
}

