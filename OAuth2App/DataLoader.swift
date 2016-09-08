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
	func authorize(from window: NSWindow?, callback: @escaping (_ authParams: OAuth2JSON?, _ error: Error?) -> Void)
	
	/** Perform a request against the GitHub API and return decoded JSON or an NSError. */
	func request(path: String, callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void))
	
	
	// MARK: - Convenience
	
	func requestUserdata(callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void))
	
	func isAuthorized() -> Bool
}


extension DataLoader {
	
	func isAuthorized() -> Bool {
		return oauth2.hasUnexpiredAccessToken()
	}
	
	func authorize(from window: NSWindow?, callback: @escaping (_ authParams: OAuth2JSON?, _ error: Error?) -> Void) {
		oauth2.authConfig.authorizeEmbedded = true
		oauth2.authConfig.authorizeContext = window
		oauth2.authorize(callback: callback)
	}
	
	func handleRedirectURL(_ url: URL) {
		oauth2.handleRedirectURL(url)
	}
}

