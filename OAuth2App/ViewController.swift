//
//  ViewController.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/12/14.
//  CC0, Public Domain
//

import Cocoa
import Quartz


class ViewController: NSViewController
{
	lazy var loader = GitHubLoader.sharedInstance
	//lazy var loader = RedditLoader.sharedInstance
	
	@IBOutlet var button: NSButton?
	
	@IBOutlet var image: IKImageView?
	
	@IBOutlet var label: NSTextField?
	
	/** Alert or log the given error message. */
	func showError(error: NSError) {
		if let window = self.view.window {
			NSAlert(error: error).beginSheetModalForWindow(window, completionHandler: nil)
		}
		else {
			NSLog("Error authorizing: \(error.localizedDescription)")
		}
	}
	
	
	// MARK: - Authorization
	
	@IBAction func requestToken(sender: NSButton?) {
		button?.title = "Authorizing..."
		button?.enabled = false
		
		loader.authorize() { didFail, error in
			self.didAuthorize(didFail, error: error)
		}
	}
	
	func didAuthorize(didFail: Bool, error: NSError?) {
		if didFail {
			button?.title = "Failed. Try Again."
			button?.enabled = true
			if nil != error {
				showError(error!)
			}
		}
		else {
			button?.title = "Authorized!"
			label?.stringValue = "Fetching user data..."
			showUserData()
		}
	}
	
	
	// MARK: - Data Requests
	
	func showUserData() {
		loader.requestUserdata() { dict, error in
			if nil != error {
				self.showError(error!)
			}
			else {
				if let imgURL = dict?["avatar_url"] as? String {
					self.image?.setImageWithURL(NSURL(string: imgURL)!)
				}
				if let username = dict?["name"] as? String {
					self.label?.stringValue = "Hello there, \(username)!"
				}
			}
		}
	}
}

