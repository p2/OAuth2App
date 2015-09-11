//
//  GitHubLoader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/12/14.
//  CC0, Public Domain
//

import Cocoa
import OAuth2


/**
	Simple class handling authorization and data requests with GitHub.
 */
class GitHubLoader
{
	static var sharedInstance = GitHubLoader()
	
	class func handleRedirectURL(url: NSURL) {
		sharedInstance.oauth2.handleRedirectURL(url)
	}
	
	
	// MARK: - Instance
	
	let baseURL = NSURL(string: "https://api.github.com")!
	
	lazy var oauth2: OAuth2CodeGrant = OAuth2CodeGrant(settings: [
		"client_id": "8ae913c685556e73a16f",                         // yes, this client-id and secret will work!
		"client_secret": "60d81efcc5293fd1d096854f4eee0764edb2da5d",
		"authorize_uri": "https://github.com/login/oauth/authorize",
		"token_uri": "https://github.com/login/oauth/access_token",
		"scope": "user repo:status",
		"redirect_uris": ["ppoauthapp://oauth/callback"],            // app has registered this scheme
		"secret_in_body": true,                                      // GitHub does not accept client secret in the Authorization header
		"verbose": true,
	])
	
	/** Start the OAuth dance. */
	func authorize(callback: (wasFailure: Bool, error: NSError?) -> Void) {
		oauth2.afterAuthorizeOrFailure = callback
		oauth2.authorize()
	}
	
	/** Perform a request against the GitHub API and return decoded JSON or an NSError. */
	func request(path: String, callback: ((dict: NSDictionary?, error: NSError?) -> Void)) {
		let url = baseURL.URLByAppendingPathComponent(path)
		let req = oauth2.request(forURL: url)
		req.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
		
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(req) { data, response, error in
			if nil != error {
				dispatch_async(dispatch_get_main_queue()) {
					callback(dict: nil, error: error)
				}
			}
			else {
				do {
					let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
					dispatch_async(dispatch_get_main_queue()) {
						callback(dict: dict, error: nil)
					}
				}
				catch let error {
					dispatch_async(dispatch_get_main_queue()) {
						callback(dict: nil, error: error as NSError)
					}
				}
			}
		}
		task.resume()
	}
	
	
	// MARK: - Convenience
	
	func requestUserdata(callback: ((dict: NSDictionary?, error: NSError?) -> Void)) {
		request("user", callback: callback)
	}
}

