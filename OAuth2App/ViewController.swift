//
//  ViewController.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/12/14.
//  CC0, Public Domain
//

import Cocoa

class ViewController: NSViewController
{
	@IBOutlet var button: NSButton?
	
	@IBAction func requestToken(sender: NSButton?) {
		if let app = NSApp?.delegate as? AppDelegate {
			button?.title = "Authorizing..."
			button?.enabled = false
			
			app.requestToken { didFail, error in
				self.didAuthorize(didFail, error: error)
			}
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
		}
	}
	
	func showError(error: NSError) {
		if let window = self.view.window {
			NSAlert(error: error).beginSheetModalForWindow(window, completionHandler: nil)
		}
		else {
			NSLog("Error authorizing: \(error.localizedDescription)")
		}
	}
}

