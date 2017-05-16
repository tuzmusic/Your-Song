//
//  AppDelegate.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleSignIn
import GGLCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
	
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		print("Documents folder: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
		
		// Initialize Google sign-in
		var configureError: NSError?
		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(String(describing:configureError))")
		GIDSignIn.sharedInstance().delegate = self
		
		// For automatic sign-in?
		// GIDSignIn.sharedInstance().signInSilently() {
		
		YpbApp.setupOfflineRealm()
		YpbApp.setupRealm()

		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		
		// Gets called after sign-in succeeds in safari, before it returns to this app
		return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
		                                         annotation: options[UIApplicationOpenURLOptionsKey.annotation])
	}
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		// The sign-in flow has finished (asyncronously) and was successful if |error| is |nil|.
		guard error == nil else {
			print("\(error.localizedDescription)")
			return
		}

		YpbApp.ypbUser = YpbUser.user(firstName: user.profile.givenName, lastName: user.profile.familyName, email: user.profile.email, in: YpbApp.ypbRealm)

		// Some more google user info
		/*
		let userId = user.userID                  // For client-side use only!
		let idToken = user.authentication.idToken // Safe to send to the server
		*/
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		// ...
	}
}

