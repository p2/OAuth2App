//
//  ViewController.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/12/14.
//  CC0, Public Domain
//

import Cocoa
import Quartz
import OAuth2


let OAuth2AppDidReceiveCallbackNotification = "OAuth2AppDidReceiveCallback"


class ViewController: NSViewController {
	
	var loader: DataLoader!
	
	@IBOutlet var button: NSButton?
	
	@IBOutlet var pasteButton: NSButton?
	
	@IBOutlet var image: IKImageView?
	
	@IBOutlet var label: NSTextField?
	
	var nextActionForgetsTokens = false
	
	
	// MARK: - Error Handling
	
	/** Forwards to `displayError(NSError)`. */
	func showError(error: ErrorType) {
		if let error = error as? OAuth2Error {
			let err = NSError(domain: "OAuth2ErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: error.description])
			displayError(err)
		}
		else {
			displayError(error as NSError)
		}
	}
	
	/** Alert or log the given NSError. */
	func displayError(error: NSError) {
		if let window = self.view.window {
			NSAlert(error: error).beginSheetModalForWindow(window, completionHandler: nil)
			label?.stringValue = error.localizedDescription
		}
		else {
			NSLog("Error authorizing: \(error.description)")
		}
	}
	
	
	// MARK: - Authorization
	
	@IBAction func requestToken(sender: NSButton?) {
		if nextActionForgetsTokens {
			nextActionForgetsTokens = false
			forgetTokens(sender)
			return
		}
		button?.title = "Authorizing..."
		button?.enabled = false
		pasteButton?.hidden = false
		label?.hidden = true
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.handleRedirect(_:)), name: OAuth2AppDidReceiveCallbackNotification, object: nil)
		loader.authorize(view.window) { didFail, error in
			self.didAuthorize(didFail, error: error)
		}
	}
	
	func handleRedirect(notification: NSNotification) {
		pasteButton?.hidden = true
		if let url = notification.object as? NSURL {
			loader.handleRedirectURL(url)
		}
		else {
			showError(NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid notification: did not contain a URL"]))
		}
	}
	
	func didAuthorize(didFail: Bool, error: ErrorType?) {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: OAuth2AppDidReceiveCallbackNotification, object: nil)
		
		if didFail {
			button?.title = "Failed. Try Again."
			if let error = error {
				showError(error)
			}
		}
		else {
			nextActionForgetsTokens = true
			button?.title = "Forget Tokens"
			label?.stringValue = "Fetching user data..."
			showUserData()
		}
		button?.enabled = true
		pasteButton?.hidden = true
		label?.hidden = false
	}
	
	@IBAction func forgetTokens(sender: NSButton?) {
		button?.title = "Forgetting..."
		loader.oauth2.forgetTokens()
		button?.title = "Authorize"
		pasteButton?.hidden = true
		label?.hidden = false
	}
	
	
	// MARK: - Data Requests
	
	func showUserData() {
		loader.requestUserdata() { dict, error in
			if let error = error {
				self.showError(error)
			}
			else {
				if let imgURL = dict?["avatar_url"] as? String {
					self.image?.setImageWithURL(NSURL(string: imgURL)!)
				}
				if let username = dict?["name"] as? String {
					self.label?.stringValue = "Hello there, \(username)!"
				}
				else {
					self.label?.stringValue = "Failed to fetch your name"
					NSLog("Fetched: \(dict)")
				}
			}
		}
	}
	
	
	// MARK: - Utilities
	
	@IBAction func paste(sender: AnyObject?) {
		let pboard = NSPasteboard.generalPasteboard()
		if let pasted = pboard.stringForType(NSPasteboardTypeString) {
			pasteButton?.hidden = true
			label?.hidden = false
			loader.oauth2.exchangeCodeForToken(pasted)
		}
		else {
			showError(OAuth2Error.Generic("Nothing in the clipboard that I can read"))
		}
	}
}

