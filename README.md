OAuth 2 App
===========

Terribly simple **OS X Swift App** to demonstrate use of the [Swift OAuth2 Framework][oauth2] against the GitHub API.
It lets you login to GitHub and then pulls your user information, displaying your avatar and full name
(for some reason the avatar doesn't automatically center; resize the window for that to happen).
The OAuth2 library is added as a Swift Package dependency.

Take a look at the [`GitHubLoader`][gh] class, which is intended to be used as a singleton and handles the OAuth flow as well as requests to the GitHub API.

There also is a deprecated [iOS Sample App](https://github.com/p2/OAuth2PodApp) which uses Cocoapods to integrate the OAuth2 framework.
Cocoapods is no longer supported for OAuth2 since version 5.1.


Installation
------------

Do a checkout, then open the project in Xcode 11 or newer and run it:

    $ git clone https://github.com/p2/OAuth2App.git


License
=======

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)][cc0]

<a rel="dct:publisher" href="https://github.com/p2/OAuth2App">I have waived</a> all copyright and related or neighboring rights to <span property="dct:title">OAuth2App</span>.

[oauth2]: https://github.com/p2/OAuth2
[gh]: https://github.com/p2/OAuth2App/blob/master/OAuth2App/GitHubLoader.swift
[cc0]: http://creativecommons.org/publicdomain/zero/1.0/
