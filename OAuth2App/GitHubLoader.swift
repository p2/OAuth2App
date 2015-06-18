//
//  GitHubLoader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 11/12/14.
//  CC0, Public Domain
//

import Cocoa
import OAuth2


let GitHubSettings = [
	"client_id": "8ae913c685556e73a16f",                         // yes, this client-id and secret will work!
	"client_secret": "60d81efcc5293fd1d096854f4eee0764edb2da5d",
	"authorize_uri": "https://github.com/login/oauth/authorize",
	"token_uri": "https://github.com/login/oauth/access_token",
	"scope": "user repo:status",
	"redirect_uris": ["ppoauthapp://oauth/callback"],            // app has registered this scheme
	"secret_in_body": true,                                      // GitHub does not accept client secret in the Authorization header
	"verbose": true,
]


/**
	Simple class handling authorization and data requests with GitHub.
 */
class GitHubLoader: Loader
{
	static let sharedInstance = GitHubLoader()
	
	
	// MARK: - Instance
	
	let baseURL = NSURL(string: "https://api.github.com")!
	
	lazy var oauth2 = OAuth2CodeGrant(settings: GitHubSettings)
	
	
	// MARK: - Convenience
	
	func requestUserdata(callback: ((dict: NSDictionary?, error: NSError?) -> Void)) {
		request("user", callback: callback)
	}
}

