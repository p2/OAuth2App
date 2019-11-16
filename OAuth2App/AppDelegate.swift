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
class AppDelegate: NSObject, NSApplicationDelegate {
	
	// register our app to get notified when launched via URL
	func applicationWillFinishLaunching(_ notification: Notification) {
		NSAppleEventManager.shared().setEventHandler(
			self,
			andSelector: #selector(AppDelegate.handleURLEvent(_:withReply:)),
			forEventClass: AEEventClass(kInternetEventClass),
			andEventID: AEEventID(kAEGetURL)
		)
	}
	
	/** Gets called when the App launches/opens via URL. */
	@objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
		if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
			if let url = URL(string: urlString), "ppoauthapp" == url.scheme && "oauth" == url.host {
				NotificationCenter.default.post(name: OAuth2AppDidReceiveCallbackNotification, object: url)
			}
		}
		else {
			NSLog("No valid URL to handle")
		}
	}
}

