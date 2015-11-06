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
	// register our app to get notified when launched via URL
	func applicationWillFinishLaunching(notification: NSNotification) {
		NSAppleEventManager.sharedAppleEventManager().setEventHandler(
			self,
			andSelector: "handleURLEvent:withReply:",
			forEventClass: AEEventClass(kInternetEventClass),
			andEventID: AEEventID(kAEGetURL)
		)
	}
	
	/** Gets called when the App launches/opens via URL. */
	func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
		if let urlString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
			if let url = NSURL(string: urlString) where "ppoauthapp" == url.scheme && "oauth" == url.host {
				NSNotificationCenter.defaultCenter().postNotificationName(OAuth2AppDidReceiveCallbackNotification, object: url)
			}
		}
		else {
			NSLog("No valid URL to handle")
		}
	}
}

