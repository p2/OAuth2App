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
class RedditLoader: OAuth2DataLoader, DataLoader {
	
	let baseURL = URL(string: "https://oauth.reddit.com")!
	
	public init() {
		let oauth = OAuth2CodeGrant(settings: [
			"client_id": "IByhV1ZcpTI6zQ",                              // yes, this client-id will work!
			"client_secret": "",
			"authorize_uri": "https://www.reddit.com/api/v1/authorize",
			"token_uri": "https://www.reddit.com/api/v1/access_token",
			"scope": "identity",                                        // note that reddit uses comma-separated, not space-separated scopes!
			"redirect_uris": ["ppoauthapp://oauth/callback"],           // app has registered this scheme
		//	"parameters": ["duration": "permanent"],
		])
		oauth.authConfig.authorizeEmbedded = true
		oauth.logger = OAuth2DebugLogger(.trace)
		super.init(oauth2: oauth)
		alsoIntercept403 = true
	}
	
	/** Perform a request against the API and return decoded JSON or an Error. */
	func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
		let url = baseURL.appendingPathComponent(path)
		let req = oauth2.request(forURL: url)
		
		perform(request: req) { response in
			do {
				let dict = try response.responseJSON()
				if response.response.statusCode < 400 {
					DispatchQueue.main.async() {
						callback(dict, nil)
					}
				}
				else {
					DispatchQueue.main.async() {
						callback(nil, OAuth2Error.generic("\(response.response.statusCode)"))
					}
				}
			}
			catch let error {
				DispatchQueue.main.async() {
					callback(nil, error)
				}
			}
		}
	}
	
	func requestUserdata(callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void)) {
		request(path: "api/v1/me", callback: callback)
	}
}

