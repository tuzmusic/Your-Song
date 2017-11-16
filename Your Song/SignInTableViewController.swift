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

	// MARK: Outlets and variables
	
	var spinner: UIActivityIndicatorView!

	let googleLoginButton = GIDSignInButton()
	
	@IBOutlet weak var contentViewForGoogleButton: UIView!

	
	func addGoogleLoginButton() {
		googleLoginButton.center = contentViewForGoogleButton.center
		//googleLoginButton.bounds.size = CGSize(width: facebookLoginButton.bounds.width + 8, height: googleLoginButton.bounds.height)
		
		contentViewForGoogleButton.addSubview(googleLoginButton)
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		spinner = view.addNewSpinner()
		spinner.stopAnimating()
		
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

		// If not already signed in, present sign-in results
		guard GIDSignIn.sharedInstance().currentUser != nil else {
			let alert = UIAlertController(title: "Google Login Failed", message: "Not signed in", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
			present(alert, animated: true, completion: nil)
			spinner.stopAnimating()
			return
		}
		
		performSegue(withIdentifier: Storyboard.LoginSegue, sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
