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
class BitBucketLoader: OAuth2DataLoader, DataLoader {
	
	let baseURL = URL(string: "https://api.bitbucket.org/2.0/")!
	
	public init() {
		let oauth = OAuth2CodeGrant(settings: [
			"client_id": "DPv2YpXLJnNcFxX3uA",                         // yes, this client-id and secret will work!
			"client_secret": "VHEqMNgWTmy5ZcDa5WUqg2ZUxpSULSna",
			"authorize_uri": "https://bitbucket.org/site/oauth2/authorize",
			"token_uri": "https://bitbucket.org/site/oauth2/access_token",
			"scope": "account",
			"redirect_uris": ["ppoauthapp://oauth/callback"],            // app has registered this scheme
			"keychain_access_group": "BitGroup",
			"verbose": true,
		])
		super.init(oauth2: oauth)
	}
	
	
	/** Perform a request against the BitBucket API and return decoded JSON or an NSError. */
	func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
		let url = baseURL.appendingPathComponent(path)
		var req = oauth2.request(forURL: url)
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		
		perform(request: req) { response in
			do {
				var dict = try response.responseJSON()
				dict["name"] = dict["display_name"] ?? "unknown"
				dict["avatar_url"] = ((dict["links"] as? [String: OAuth2JSON])?["avatar"] as? [String: String])?["href"]
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

