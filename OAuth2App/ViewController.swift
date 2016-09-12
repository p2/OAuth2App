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
	
	
	// MARK: - Authorization
	
	func handleRedirect(_ notification: Notification) {
		pasteButton?.isHidden = true
		if let url = notification.object as? URL {
			label?.stringValue = "Handling redirect..."
			do {
				try loader.oauth2.handleRedirectURL(url)
			}
			catch let error {
				show(error)
			}
		}
		else {
			show(NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid notification: did not contain a URL"]))
		}
	}
	
	@IBAction func forgetTokens(_ sender: NSButton?) {
		button?.title = "Forgetting..."
		loader.oauth2.forgetTokens()
		button?.title = "Load Userdata"
		pasteButton?.isHidden = true
		label?.isHidden = false
	}
	
	
	// MARK: - Data Requests
	
	@IBAction func startLoading(_ sender: NSButton?) {
		if nextActionForgetsTokens {
			nextActionForgetsTokens = false
			forgetTokens(sender)
			return
		}
		
		// show what is happening
		button?.title = "Authorizing..."
		button?.isEnabled = false
		pasteButton?.isHidden = false
		label?.isHidden = true
		
		// config OAuth2
		loader.oauth2.authConfig.authorizeContext = view.window
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleRedirect(_:)), name: NSNotification.Name(rawValue: OAuth2AppDidReceiveCallbackNotification), object: nil)
		
		// load user data
		loader.requestUserdata() { dict, error in
			if let error = error {
				self.button?.title = "Failed. Try Again."
				self.show(error)
			}
			else {
				if let imgURL = dict?["avatar_url"] as? String {
					self.image?.setImageWith(URL(string: imgURL)!)
				}
				if let username = dict?["name"] as? String {
					self.label?.stringValue = "Hello there, \(username)!"
				}
				else {
					self.label?.stringValue = "Failed to fetch your name"
					NSLog("Fetched: \(dict)")
				}
				self.nextActionForgetsTokens = true
				self.button?.title = "Forget Tokens"
			}
			self.button?.isEnabled = true
			self.pasteButton?.isHidden = true
			self.label?.isHidden = false
		}
	}
	
	
	// MARK: - Error Handling
	
	/** Forwards to `display(error:)`. */
	func show(_ error: Error) {
		if let error = error as? OAuth2Error {
			let err = NSError(domain: "OAuth2ErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: error.description])
			display(err)
		}
		else {
			display(error as NSError)
		}
	}
	
	/** Alert or log the given NSError. */
	func display(_ error: NSError) {
		if let window = self.view.window {
			NSAlert(error: error).beginSheetModal(for: window, completionHandler: nil)
			label?.stringValue = error.localizedDescription
		}
		else {
			NSLog("Error authorizing: \(error.description)")
		}
	}
	
	
	// MARK: - Utilities
	
	@IBAction func paste(_ sender: AnyObject?) {
		let pboard = NSPasteboard.general()
		if let pasted = pboard.string(forType: NSPasteboardTypeString) {
			pasteButton?.isHidden = true
			label?.isHidden = false
			if let oa2 = loader.oauth2 as? OAuth2CodeGrant {
				oa2.exchangeCodeForToken(pasted)
			}
			else {
				show(OAuth2Error.generic("The OAuth2 instance is not a code exchange grant, cannot exchange code"))
			}
		}
		else {
			show(OAuth2Error.generic("Nothing in the clipboard that I can read"))
		}
	}
}

