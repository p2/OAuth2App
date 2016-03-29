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
	
	func handleRedirectURL(url: NSURL)
	
	/** Start the OAuth dance. */
	func authorize(window: NSWindow?, callback: (wasFailure: Bool, error: ErrorType?) -> Void)
	
	/** Perform a request against the GitHub API and return decoded JSON or an NSError. */
	func request(path: String, callback: ((dict: OAuth2JSON?, error: ErrorType?) -> Void))
	
	
	// MARK: - Convenience
	
	func requestUserdata(callback: ((dict: OAuth2JSON?, error: ErrorType?) -> Void))
	
	func isAuthorized() -> Bool
}


extension DataLoader {
	
	func isAuthorized() -> Bool {
		return oauth2.hasUnexpiredAccessToken()
	}
	
	func authorize(window: NSWindow?, callback: (wasFailure: Bool, error: ErrorType?) -> Void) {
		oauth2.authConfig.authorizeEmbedded = true
		oauth2.authConfig.authorizeContext = window
		oauth2.afterAuthorizeOrFailure = callback
		oauth2.authorize()
	}
	
	func handleRedirectURL(url: NSURL) {
		oauth2.handleRedirectURL(url)
	}
}

