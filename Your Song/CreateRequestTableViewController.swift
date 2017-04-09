//
//  CreateRequestTableViewController.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/18/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

class CreateRequestTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
	
	// MARK: Request model
	
	struct RequestFieldIndices {
		static let Name = 0
		static let Song = 1
		static let Notes = 2
	}
	
	var realm: Realm?
	var notificationToken: NotificationToken!
	
	var request: Request!
	
	// MARK: Text field/view outlets and delegate methods
	
	@IBOutlet var requestTextFields: [UITextField]!
		// { didSet {	requestTextFields[0].text = SyncUser.current!.username	} }
	@IBOutlet weak var notesTextView: UITextView!
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if let text = textField.text {
			switch textField {
			case requestTextFields[0]: request.userString = text
			case requestTextFields[1]: request.songString = text
			default: break
			}
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		request.notes = textView.text
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		// Set text for section header
		var string = ""
		switch section {
		case 0: string = " Your Name"
		case 1: string = " Your Song"
		case 2: string = " Your Notes/Dedication"
		default: break
		}
		
		// Create view and format text
		let label = UILabel()
		let fullRange = NSRange(location: 0, length: string.characters.count)
		let header = NSMutableAttributedString(string: string)
		
		let boldTrait = [UIFontWeightTrait : UIFontWeightBold]
		let descriptors = UIFontDescriptor(fontAttributes:
			[UIFontDescriptorNameAttribute : "BebasNeue",
			 UIFontDescriptorTraitsAttribute : boldTrait ])
		let font = UIFont(descriptor: descriptors, size: 18)
		
		//header.addAttribute(NSFontAttributeName, value: UIFont(name: "BebasNeue", size: 18)!, range: fullRange)
		header.addAttribute(NSFontAttributeName, value:font, range: fullRange)
		header.addAttribute(NSKernAttributeName, value: 2, range: fullRange)
		header.addAttribute(NSForegroundColorAttributeName, value: ypbOrange, range: fullRange)
		//header.addAttribute(NSBackgroundColorAttributeName, value: ypbBlack, range: fullRange)
		
		label.attributedText = header
		return label
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// If a song has been selected from browser, put it in the text field.
		if let request = request, !request.songString.isEmpty {
			requestTextFields[RequestFieldIndices.Song].text = request.songString
		}
	}

	// MARK: Submitting the request
	
	@IBAction func submitButtonPressed(_ sender: UIButton) {

		requestTextFields.forEach { $0.resignFirstResponder() }
		notesTextView.resignFirstResponder()
		
		guard request != nil && !request.userString.isEmpty && !request.songString.isEmpty else {
			let alert = UIAlertController(title: "Incomplete Request",
			                              message: "Please enter your name and a song.",
			                              preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		}
		
		// Store non-user-accessible request info
		request.date = Date()
		
		do {
			if let realm = realm {
				try realm.write {
					realm.add(request)
				}
				func confirmSubmittedRequest() {
					var infoString = "Your Name: \(request.userString)" + "\r"
					infoString += "Your Song: \(request.songString)" + "\r"
					infoString += "Your Notes: \(request.notes)"
					let alert = UIAlertController(title: "Request Sent!", message: infoString, preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
						self.requestTextFields.forEach { $0.text = "" }
						self.notesTextView.text = ""
						self.request = Request()
					})
					present(alert, animated: true, completion: nil)
				}
				confirmSubmittedRequest()
			} else {
				let alert = UIAlertController(title: "Request Not Sent", message: "realm = nil", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				present(alert, animated: true, completion: nil)
			}
		} catch {
			let alert = UIAlertController(title: "Error",
			                              //message: String(describing: error),
				message: "Could not write to the Realm.",
				preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// setupOnlineRequestRealm()
		// The problem appears to be here. Leaving the song picker resets request to nil
		if request == nil {
			request = Request()
		}
	}
	
	func setupOnlineRequestRealm() {
		let username = "tuzmusic@gmail.com"
		let password = "***REMOVED***"
		
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		let realmAddress = URL(string:"realm://54.208.237.32:9080/~/yourPianoBarRequests")!
		
		/* to SSH in via terminal:
		cd /Users/TuzsNewMacBook/Library/Mobile\ Documents/com\~apple\~CloudDocs/Misc\ Stuff\ -\ iCloud\ drive/Programming/IMPORTANT\ Server\ Stuff
		ssh -i "YourPianoBarKeyPair.pem" ubuntu@ec2-54-208-237-32.compute-1.amazonaws.com
		
		sudo systemctl start realm-object-server

		*/
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
			user, error in
			guard let user = user else {
				let alert = UIAlertController(title: "Error",
				                              //message: String(describing: error),
					message: "Could not log in",
					preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)
				print(String(describing: error!))
				return
			}
			
			DispatchQueue.main.async {
				
				// Open Realm
				var configuration = Realm.Configuration()
				configuration.syncConfiguration = SyncConfiguration(user: user, realmURL: realmAddress)
				
				do {
					self.realm = try Realm(configuration: configuration)
				} catch {
					print(error)
				}
			}
		}
	}

	deinit {
		notificationToken.stop()
	}
}
