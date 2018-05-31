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

class CreateRequestTableViewController: UITableViewController, RealmDelegate {
	
	var realm: Realm?	// passed from sign-in VC
	var request: Request!	// TO-DO: I think this can be a local variable within submitRequest. Does that matter?
	
	let thanksString = "Thanks for your request! Keep your ears peeled and get ready to sing along!"
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		navigationController?.viewControllers = [self]
//		navigationItem.leftItemsSupplementBackButton = true
//		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem

		resetRequest()
	}
	
	@IBAction func showMenu() {
		if let masterNav = splitViewController?.viewControllers.first as? UINavigationController,
			let master = masterNav.topViewController {
//			show(master, sender: nil)
		}
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
		let spinner = view.addNewSpinner()
		
		guard let name = nameTextField.text, let song = songTextField.text else {
			self.present(UIAlertController.basic(title: "Whoops!", message: "Please enter your name and a song."), animated: true)
			return
		}
		
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
			present(UIAlertController.basic(title: "Uh oh", message: "\(error)"), animated: true)
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
		if let songsVC = segue.destination as? SongsTableViewController_0518 {
			songsVC.realm = self.realm
		}
		if let searchVC = segue.destination as? RealmSearchViewController {
			searchVC.realmConfiguration = realm!.configuration
		}
	}
}
