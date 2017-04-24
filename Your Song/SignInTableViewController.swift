//
//  SignInTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/23/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignInTableViewController: UITableViewController, GIDSignInUIDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		GIDSignIn.sharedInstance().uiDelegate = self
		
  // Uncomment to automatically sign in the user.
  // GIDSignIn.sharedInstance().signInSilently()
		
  // TODO(developer) Configure the sign-in button look/feel
  // ...
		
	}

	@IBAction func googleSignOut(_ sender: Any) {
		GIDSignIn.sharedInstance().signOut()
	}
	
	var googleUser: GIDGoogleUser?
	
	@IBAction func signIn(_ sender: Any) {
		if sender is GIDSignInButton {
		googleUser = GIDSignIn.sharedInstance().currentUser
			if let user = googleUser {
				pr("Google User Info: \(user.profile.name!), \(user.profile.email!)")
			} else {
				print("Not signed in yet")
				return
			}
		}
		performSegue(withIdentifier: Storyboard.LoginSegue, sender: nil)
	}
}
