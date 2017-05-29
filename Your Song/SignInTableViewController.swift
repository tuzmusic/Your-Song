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

class SignInTableViewController: UITableViewController, GIDSignInUIDelegate {
	
	func addNewSpinner() -> UIActivityIndicatorView {
		let spinner = UIActivityIndicatorView()
		spinner.frame.origin.x = view.frame.midX - 20
		spinner.frame.origin.y = view.frame.midY - 20
		spinner.frame.size = CGSize(width: 40, height: 40)
		spinner.hidesWhenStopped = true
		spinner.activityIndicatorViewStyle = .whiteLarge
		spinner.color = .lightGray
		spinner.startAnimating()
		view.addSubview(spinner)
		return spinner
	}

	@IBOutlet weak var googleButtonView: UIView!
	@IBOutlet weak var facebookButtonView: LoginButton!
	@IBOutlet weak var contentViewForFacebookButton: UIView!
	
	func addFacebookLoginButton () {
		let facebookLoginButton = LoginButton(readPermissions: [ .publicProfile ])
		facebookLoginButton.center = contentViewForFacebookButton.center
		contentViewForFacebookButton.addSubview(facebookLoginButton)
		
		googleButtonView.bounds = facebookLoginButton.bounds
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		GIDSignIn.sharedInstance().uiDelegate = self
		
		addFacebookLoginButton()
		
		// Uncomment to automatically sign in the user.
		/* GIDSignIn.sharedInstance().signInSilently()
		
		// TODO(developer) Configure the sign-in button look/feel
		// ...
		*/
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		googleButtonView.bounds = facebookLoginButton.bounds

	}
	
	var spinner: UIActivityIndicatorView!
	
	// note: maybe this should be:
	// 	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)

	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		pr("GIDSignInUIDelegate signed-in method")

		guard GIDSignIn.sharedInstance().currentUser != nil else {
			let alert = UIAlertController(title: "Google Login Failed", message: "Not signed in", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
			//present(alert, animated: true, completion: nil)
			spinner.stopAnimating()
			return
		}
		
		performSegue(withIdentifier: Storyboard.LoginSegue, sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		pr("prepare for segue")
		spinner.stopAnimating()
	}
	
	@IBAction func signIn(_ sender: Any) {
		pr("signIn")
		spinner = addNewSpinner()
	}
	
	@IBAction func googleSignOut(_ sender: Any) {
		GIDSignIn.sharedInstance().signOut()
	}
}
