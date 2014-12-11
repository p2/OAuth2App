//
//  AppDelegate.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/12/14.
//  CC0, Public Domain
//

import Cocoa
import OAuth2

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
	lazy var oauth2 = OAuth2CodeGrant(settings: [
		"client_id": "8ae913c685556e73a16f",                         // yes, this client-id and secret will work!
		"client_secret": "60d81efcc5293fd1d096854f4eee0764edb2da5d",
		"authorize_uri": "https://github.com/login/oauth/authorize",
		"token_uri": "https://github.com/login/oauth/access_token",
		"scope": "user repo:status",
		"redirect_uris": ["ppoauthapp://oauth/callback"],            // don't forget to register this scheme
	])
	
	func applicationWillFinishLaunching(notification: NSNotification) {
		// register our app to get notified when launched via URL
		NSAppleEventManager.sharedAppleEventManager().setEventHandler(
			self,
			andSelector: "handleURLEvent:withReply:",
			forEventClass: AEEventClass(kInternetEventClass),
			andEventID: AEEventID(kAEGetURL)
		)
	}
	
	
	// MARK: - OAuth2
	
	func requestToken(callback: (wasFailure: Bool, error: NSError?) -> Void) {
		oauth2.afterAuthorizeOrFailure = callback
		
		let url = oauth2.authorizeURL()
		NSWorkspace.sharedWorkspace().openURL(url)
	}
	
	/** Gets called when the App launches/opens via URL. */
	func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
		if let urlString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
			let url = NSURL(string: urlString)
			if "ppoauthapp" == url?.scheme && "oauth" == url?.host {
				oauth2.handleRedirectURL(url!)
			}
		}
		else {
			NSLog("No valid URL to handle")
		}
	}
}

