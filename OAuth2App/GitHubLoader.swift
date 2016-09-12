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
class GitHubLoader: OAuth2DataLoader, DataLoader {
	
	let baseURL = URL(string: "https://api.github.com")!
	
	public init() {
		let oauth = OAuth2CodeGrant(settings: [
			"client_id": "8ae913c685556e73a16f",                         // yes, this client-id and secret will work!
			"client_secret": "60d81efcc5293fd1d096854f4eee0764edb2da5d",
			"authorize_uri": "https://github.com/login/oauth/authorize",
			"token_uri": "https://github.com/login/oauth/access_token",
			"scope": "user repo:status",
			"redirect_uris": ["ppoauthapp://oauth/callback"],            // app has registered this scheme
			"secret_in_body": true,                                      // GitHub does not accept client secret in the Authorization header
			"verbose": true,
		])
		super.init(oauth2: oauth)
	}
	
	
	/** Perform a request against the GitHub API and return decoded JSON or an NSError. */
	func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
		oauth2.logger = OAuth2DebugLogger(.trace)
		let url = baseURL.appendingPathComponent(path)
		var req = oauth2.request(forURL: url)
		req.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
		
		perform(request: req) { response in
			do {
				let dict = try response.responseJSON()
				DispatchQueue.main.async() {
					callback(dict, nil)
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
		request(path: "user", callback: callback)
	}
}

