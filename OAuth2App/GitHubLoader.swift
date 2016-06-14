//
//  GitHubLoader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/12/14.
//  CC0, Public Domain
//

import Foundation
import OAuth2


/**
	Simple class handling authorization and data requests with GitHub.
 */
class GitHubLoader: DataLoader {
	
	let baseURL = URL(string: "https://api.github.com")!
	
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
	
	
	/** Perform a request against the GitHub API and return decoded JSON or an NSError. */
	func request(_ path: String, callback: ((dict: OAuth2JSON?, error: ErrorProtocol?) -> Void)) {
		oauth2.logger = OAuth2DebugLogger(.trace)
		guard let url = try? baseURL.appendingPathComponent(path) else {
			callback(dict: nil, error: OAuth2Error.generic("Cannot append path «\(path)» to base URL"))
			return
		}
		var req = oauth2.request(forURL: url)
		req.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
		
		let task = oauth2.session.dataTask(with: req) { data, response, error in
			if nil != error {
				DispatchQueue.main.async() {
					callback(dict: nil, error: error)
				}
			}
			else {
				do {
					let dict = try JSONSerialization.jsonObject(with: data!, options: []) as? OAuth2JSON
					DispatchQueue.main.async() {
						callback(dict: dict, error: nil)
					}
				}
				catch let error {
					DispatchQueue.main.async() {
						callback(dict: nil, error: error)
					}
				}
			}
		}
		task.resume()
	}
	
	
	// MARK: - Convenience
	
	func requestUserdata(_ callback: ((dict: OAuth2JSON?, error: ErrorProtocol?) -> Void)) {
		request("user", callback: callback)
	}
}

