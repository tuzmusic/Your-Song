//
//  CreatRequestTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 2/12/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import RealmSearchViewController

class CreateRequestTableViewController: UITableViewController, RealmDelegate, UINavigationBarDelegate {
	
	var realm: Realm?	// passed from sign-in VC
	var request: Request!	// TO-DO: I think this can be a local variable within submitRequest. Does that matter?
	
	let thanksString = "Thanks for your request! Keep your ears peeled and get ready to sing along!"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		resetRequest()
		navigationItem.hidesBackButton = true
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(confirmLogout(_:))) // hide back button?
	}
	
	@objc func confirmLogout(_ sender: Any) {
		let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?",  preferredStyle: .alert)
		
		let yesButton = UIAlertAction(title: "Log out", style: .destructive) { (_) in
			if let loginVC = self.navigationController?.viewControllers.first as? SignInTableViewController {
				self.navigationController?.popViewController(animated: true)
				loginVC.logOutAll()
			}
		}
		
		let noButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(yesButton)
		alert.addAction(noButton)
		present(alert, animated: true, completion: nil)

	}
	
	@IBOutlet weak var nameTextField: UITextField! {
		didSet {
			if let user = YpbUser.current {
				nameTextField.text = user.fullName
			}
		}
	}
	@IBOutlet weak var songTextField: UITextField!
	@IBOutlet weak var notesTextView: UITextView!
	
	@IBAction func submitRequest(_ sender: UIButton) {
		let name = nameTextField.text!
        let song = songTextField.text!
		
        guard !name.isEmpty && !song.isEmpty else {
			self.present(UIAlertController.basic(title: "Whoops!", message: "Please enter your name and a song."), animated: true)
			return
		}
        
        let spinner = view.addNewSpinner()

		request.user = YpbUser.current
		request.userString = name
		request.songString = song
		request.notes = notesTextView.text
		// request.songObject = already set if there is one
		request.date = Date()
		
		do {
			try realm?.write {
				realm?.create(Request.self, value: request, update: false)
				present(UIAlertController.basic(title: "Success!", message: thanksString), animated: true)
				resetRequest()
				spinner.stopAnimating()
			}
		} catch {
			present(UIAlertController.basic(title: "Uh oh", message: "\(error.localizedDescription)"), animated: true)
		}
	}
	
	func resetRequest() {
		request = Request()
		nameTextField.text = YpbUser.current?.fullName ?? ""
		songTextField.text = ""
		notesTextView.text = ""
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let songsVC = segue.destination as? SongsTableViewController {
			songsVC.realm = self.realm
			songsVC.requestFormDelegate = self
		}
		if let searchVC = segue.destination as? RealmSearchViewController {
			searchVC.realmConfiguration = realm!.configuration
		}
	}

    override func viewDidAppear(_ animated: Bool) {
        // place breakpoint here.
    }
}
