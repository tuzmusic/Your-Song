//
//  SignInTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/23/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookLogin
import FacebookCore

class SignInTableViewController: UITableViewController, GIDSignInUIDelegate {

	// MARK: Outlets and variables
	
	var spinner: UIActivityIndicatorView!

	let facebookLoginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
	let googleLoginButton = GIDSignInButton()
	
	@IBOutlet weak var contentViewForFacebookButton: UIView!
	@IBOutlet weak var contentViewForGoogleButton: UIView!

	func addFacebookLoginButton () {
		facebookLoginButton.center = contentViewForFacebookButton.center		
		contentViewForFacebookButton.addSubview(facebookLoginButton)
	}
	
	func addGoogleLoginButton() {
		googleLoginButton.center = contentViewForGoogleButton.center
		googleLoginButton.bounds.size = CGSize(width: facebookLoginButton.bounds.width + 8, height: googleLoginButton.bounds.height)
		
		contentViewForGoogleButton.addSubview(googleLoginButton)
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		spinner = view.addNewSpinner()
		spinner.stopAnimating()
		
		addFacebookLoginButton()
		addGoogleLoginButton()

		GIDSignIn.sharedInstance().uiDelegate = self

		// Uncomment to automatically sign in the user.
		/* GIDSignIn.sharedInstance().signInSilently()
		
		// TODO(developer) Configure the sign-in button look/feel
		// ...
		*/
		
	}
	
	// MARK: Google Login Handler
	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		pr("GIDSignInUIDelegate signed-in method")

		guard GIDSignIn.sharedInstance().currentUser != nil else {
			let alert = UIAlertController(title: "Google Login Failed", message: "Not signed in", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
			present(alert, animated: true, completion: nil)
			spinner.stopAnimating()
			return
		}
		
		performSegue(withIdentifier: Storyboard.LoginSegue, sender: nil)
	}
	
	// MARK: Facebook Login Handler

	/*	func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
		let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: accessToken.tokenString, version: nil, HTTPMethod: "GET")
		req.startWithCompletionHandler { (connection, result, error : NSError!) -> Void in
			if error == nil {
				print("result \(result)")
			} else {
				print("error \(error)")
			}
		}
	} */

	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		pr("prepare for segue")
		spinner.stopAnimating()
	}
	
	@IBAction func signIn(_ sender: Any) {
		pr("signIn")
		spinner.startAnimating()
	}
	
	@IBAction func googleSignOut(_ sender: Any) {
		GIDSignIn.sharedInstance().signOut()
	}
}
