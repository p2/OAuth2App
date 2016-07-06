//
//  RedditLoader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 3/27/15.
//  CC0, Public Domain
//

import Foundation
import OAuth2


/**
	Simple class handling authorization and data requests with Reddit.
 */
class RedditLoader: DataLoader {
	
	let baseURL = URL(string: "https://oauth.reddit.com")!

	lazy var oauth2: OAuth2CodeGrant = OAuth2CodeGrant(settings: [
		"client_id": "IByhV1ZcpTI6zQ",                              // yes, this client-id will work!
		"client_secret": "",
		"authorize_uri": "https://www.reddit.com/api/v1/authorize",
		"token_uri": "https://www.reddit.com/api/v1/access_token",
		"scope": "identity",                                        // note that reddit uses comma-separated, not space-separated scopes!
		"redirect_uris": ["ppoauthapp://oauth/callback"],           // app has registered this scheme
		"verbose": true,
	])
	
	func authorize(_ callback: (wasFailure: Bool, error: ErrorProtocol?) -> Void) {
		oauth2.authConfig.authorizeEmbedded = true
		oauth2.afterAuthorizeOrFailure = callback
		oauth2.authorize(params: ["duration": "permanent"])
	}
	
	/** Perform a request against the API and return decoded JSON or an NSError. */
	func request(_ path: String, callback: ((dict: OAuth2JSON?, error: ErrorProtocol?) -> Void)) {
		guard let url = try? baseURL.appendingPathComponent(path) else {
			callback(dict: nil, error: OAuth2Error.generic("Cannot append path «\(path)» to base URL"))
			return
		}
		let req = oauth2.request(forURL: url)
		
		let session = URLSession.shared
		let task = session.dataTask(with: req) { data, response, error in
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
		request("api/v1/me", callback: callback)
	}
}

