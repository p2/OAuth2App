//
//  LinkedInLoader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 18/11/15.
//  Copyright © 2015 Ossus. All rights reserved.
//

import Foundation
import OAuth2


class GoogleLoader: OAuth2DataLoader, DataLoader {
	
	let baseURL = URL(string: "https://www.googleapis.com")!
	
	public init() {
		let oauth = OAuth2CodeGrant(settings: [
			"client_id": "264768155148-edjhk5aclg20o4fgisblc53ne4991oc3.apps.googleusercontent.com",
			"client_secret": "qkCnyGhWf133Ydf7VVAsdxEn",
			"authorize_uri": "https://accounts.google.com/o/oauth2/auth",
			"token_uri": "https://www.googleapis.com/oauth2/v3/token",
			"scope": "profile",
			"redirect_uris": ["urn:ietf:wg:oauth:2.0:oob"],
			"verbose": true,
		])
		super.init(oauth2: oauth)
	}
	
	/** Perform a request against the API and return decoded JSON or an Error. */
	func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
		let url = baseURL.appendingPathComponent(path)
		let req = oauth2.request(forURL: url)
		
		perform(request: req) { response in
			do {
				let dict = try response.responseJSON()
				var profile = [String: String]()
				if let name = dict["displayName"] as? String {
					profile["name"] = name
				}
				if let avatar = (dict["image"] as? OAuth2JSON)?["url"] as? String {
					profile["avatar_url"] = avatar
				}
				if let error = (dict["error"] as? OAuth2JSON)?["message"] as? String {
					DispatchQueue.main.async {
						callback(nil, OAuth2Error.generic(error))
					}
				}
				else {
					DispatchQueue.main.async {
						callback(profile, nil)
					}
				}
			}
			catch let error {
				DispatchQueue.main.async {
					callback(nil, error)
				}
			}
		}
	}
	
	func requestUserdata(callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void)) {
		request(path: "plus/v1/people/me", callback: callback)
	}
}

