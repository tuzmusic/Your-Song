//
//  AppDelegate extension - GoogleSignIn.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 2/2/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import Foundation
import GoogleSignIn

extension AppDelegate: GIDSignInDelegate {
	func application(_ application: UIApplication,
				  open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		return GIDSignIn.sharedInstance().handle(url,
										 sourceApplication: sourceApplication,
										 annotation: annotation)
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
		return GIDSignIn.sharedInstance().handle(url,
										 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
										 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
	}
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		guard let user = user else {
			print("\(error.localizedDescription)")
			NotificationCenter.default.post(
				name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
			return
		}
		
		 print("Google User is signed in: \(user.profile!.email!)")		
		/* Perform any operations on signed in user here.
		let userId = user.userID                  // For client-side use only!
		let idToken = user.authentication.idToken // Safe to send to the server
		let fullName = user.profile.name
		let givenName = user.profile.givenName
		let familyName = user.profile.familyName
		let email = user.profile.email
		NotificationCenter.default.post(
		name: Notification.Name(rawValue: "ToggleAuthUINotification"),
		object: nil,
		userInfo: ["statusText": "Signed in user:\n\(fullName!)"])
		*/
	}

	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		// Perform any operations when the user disconnects from app here.
		NotificationCenter.default.post(
			name: Notification.Name(rawValue: "ToggleAuthUINotification"),
			object: nil, userInfo: ["statusText": "User has disconnected."])
	}
}
