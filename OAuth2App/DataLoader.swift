//
//  DataLoader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/6/15.
//  Copyright © 2015 Ossus. All rights reserved.
//

import Cocoa
import OAuth2


/**
Protocol for loader classes.
*/
public protocol DataLoader {
	
	var oauth2: OAuth2CodeGrant { get }
	
	func handleRedirectURL(_ url: URL)
	
	/** Start the OAuth dance. */
	func authorize(_ window: NSWindow?, callback: (authParams: OAuth2JSON?, error: ErrorProtocol?) -> Void)
	
	/** Perform a request against the GitHub API and return decoded JSON or an NSError. */
	func request(_ path: String, callback: ((dict: OAuth2JSON?, error: ErrorProtocol?) -> Void))
	
	
	// MARK: - Convenience
	
	func requestUserdata(_ callback: ((dict: OAuth2JSON?, error: ErrorProtocol?) -> Void))
	
	func isAuthorized() -> Bool
}


extension DataLoader {
	
	func isAuthorized() -> Bool {
		return oauth2.hasUnexpiredAccessToken()
	}
	
	func authorize(_ window: NSWindow?, callback: (authParams: OAuth2JSON?, error: ErrorProtocol?) -> Void) {
		oauth2.authConfig.authorizeEmbedded = true
		oauth2.authConfig.authorizeContext = window
		oauth2.authorize(callback: callback)
	}
	
	func handleRedirectURL(_ url: URL) {
		oauth2.handleRedirectURL(url)
	}
}

