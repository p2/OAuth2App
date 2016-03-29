//
//  LinkedInLoader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 18/11/15.
//  Copyright © 2015 Ossus. All rights reserved.
//

import Foundation
import OAuth2


class GoogleLoader: DataLoader {
	
	let baseURL = NSURL(string: "https://www.googleapis.com")!
	
	lazy var oauth2: OAuth2CodeGrant = OAuth2CodeGrant(settings: [
		"client_id": "abc.apps.googleusercontent.com",
		"client_secret": "def",
		"authorize_uri": "https://accounts.google.com/o/oauth2/auth",
		"token_uri": "https://www.googleapis.com/oauth2/v3/token",
		"scope": "profile",
		"redirect_uris": ["urn:ietf:wg:oauth:2.0:oob"],
		"verbose": true,
	])
	
	/** Perform a request against the API and return decoded JSON or an NSError. */
	func request(path: String, callback: ((dict: OAuth2JSON?, error: ErrorType?) -> Void)) {
		let url = baseURL.URLByAppendingPathComponent(path)
		let req = oauth2.request(forURL: url)
		
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(req) { data, response, error in
			if nil != error {
				dispatch_async(dispatch_get_main_queue()) {
					callback(dict: nil, error: error)
				}
			}
			else {
				do {
					let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! OAuth2JSON
					var profile = [String: String]()
					if let name = dict["displayName"] as? String {
						profile["name"] = name
					}
					if let avatar = (dict["image"] as? OAuth2JSON)?["url"] as? String {
						profile["avatar_url"] = avatar
					}
					dispatch_async(dispatch_get_main_queue()) {
						callback(dict: profile, error: nil)
					}
				}
				catch let error {
					dispatch_async(dispatch_get_main_queue()) {
						callback(dict: nil, error: error)
					}
				}
			}
		}
		task.resume()
	}
	
	
	// MARK: - Convenience
	
	func requestUserdata(callback: ((dict: OAuth2JSON?, error: ErrorType?) -> Void)) {
		request("plus/v1/people/me", callback: callback)
	}
}

