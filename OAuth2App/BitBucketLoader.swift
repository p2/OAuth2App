//
//  BitBucketLoader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 18/03/16.
//  CC0, Public Domain
//

import Foundation
import OAuth2


/**
Simple class handling authorization and data requests with BitBucket.
*/
class BitBucketLoader: DataLoader {
	
	let baseURL = NSURL(string: "https://api.bitbucket.org/2.0/")!
	
	lazy var oauth2: OAuth2CodeGrant = OAuth2CodeGrant(settings: [
		"client_id": "DPv2YpXLJnNcFxX3uA",                         // yes, this client-id and secret will work!
		"client_secret": "VHEqMNgWTmy5ZcDa5WUqg2ZUxpSULSna",
		"authorize_uri": "https://bitbucket.org/site/oauth2/authorize",
		"token_uri": "https://bitbucket.org/site/oauth2/access_token",
		"scope": "account",
		"redirect_uris": ["ppoauthapp://oauth/callback"],            // app has registered this scheme
		"verbose": true,
	])
	
	
	/** Perform a request against the BitBucket API and return decoded JSON or an NSError. */
	func request(path: String, callback: ((dict: OAuth2JSON?, error: ErrorType?) -> Void)) {
		let url = baseURL.URLByAppendingPathComponent(path)
		let req = oauth2.request(forURL: url)
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		
		let task = oauth2.session.dataTaskWithRequest(req) { data, response, error in
			if nil != error {
				dispatch_async(dispatch_get_main_queue()) {
					callback(dict: nil, error: error)
				}
			}
			else {
				do {
					var dict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? OAuth2JSON
					dict!["name"] = dict?["display_name"] ?? "unknown"
					dict!["avatar_url"] = ((dict?["links"] as? [String: OAuth2JSON])?["avatar"] as? [String: String])?["href"]
					dispatch_async(dispatch_get_main_queue()) {
						callback(dict: dict, error: nil)
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
		request("user", callback: callback)
	}
}

