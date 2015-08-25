//
//  Loader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 6/18/15.
//  Copyright © 2015 Ossus. All rights reserved.
//

import Foundation
import OAuth2


protocol Loader
{
	var baseURL: NSURL { get }
	
	var oauth2: OAuth2CodeGrant { get }
	
	/** Start the OAuth dance. */
	func authorize(callback: (wasFailure: Bool, error: NSError?) -> Void)
	
	/** Perform a request against the API and return decoded JSON or an NSError. */
	func request(path: String, callback: ((dict: NSDictionary?, error: NSError?) -> Void))
	
	/** Convenience method to perform a request to get user info. */
	func requestUserdata(callback: ((dict: NSDictionary?, error: NSError?) -> Void))
}


extension Loader
{
	/** Start the OAuth dance. */
	func authorize(callback: (wasFailure: Bool, error: NSError?) -> Void) {
		oauth2.afterAuthorizeOrFailure = callback
		oauth2.authorize()
	}
	
	/** Handle the redirect URL. */
	func handleRedirectURL(url: NSURL) {
		oauth2.handleRedirectURL(url)
	}
	
	/** Perform a request against the API and return decoded JSON or an NSError. */
	func request(path: String, callback: ((dict: NSDictionary?, error: NSError?) -> Void)) {
		let url = baseURL.URLByAppendingPathComponent(path)
		let req = oauth2.request(forURL: url)
		
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(req) { data, response, error in
			if let data = data {
				do {
					let dict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
					dispatch_async(dispatch_get_main_queue()) {
						callback(dict: dict, error: nil)
					}
				}
				catch let err {
					dispatch_async(dispatch_get_main_queue()) {
						callback(dict: nil, error: err as NSError)
					}
				}
			}
			else {
				dispatch_async(dispatch_get_main_queue()) {
					callback(dict: nil, error: error)
				}
			}
		}
		task.resume()
	}
}

