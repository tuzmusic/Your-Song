//
//  CreateRequestTableViewController.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/18/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

extension UITextView {
	func reset(with placeholder: String) {
		self.text = placeholder
		self.textColor = UIColor.lightGray
	}
}

class CreateRequestTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
	
	// MARK: Request model
	var realm: Realm? { return globalRealm }
	
	var request: Request!
	
	// MARK: Text field/view outlets and delegate methods
	
	let namePlaceholder = "Enter your name"
	let songPlaceholder = "Enter your song, or look for your favorite song in our catalog"
	let notesPlaceHolder = "Got a dedication? Want to come up and sing? Put any extra notes here"
	
	@IBOutlet weak var nameTextField: UITextField!
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.placeholder = ""
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField == nameTextField, let text = textField.text {
			if text == "" {
				textField.placeholder = namePlaceholder
			} else {
				request.userString = text
			}
		}
	}
	
	@IBOutlet weak var songTextView: UITextView!
	@IBOutlet weak var notesTextView: UITextView!
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		textView.text = ""
		textView.textColor = UIColor.black
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text == "" {
			textView.reset(with: textView == songTextView ? songPlaceholder : notesPlaceHolder)
		} else {
			request.setValue(textView.text, forKey: textView == songTextView ? "songString" : "notes")
		}
	}
	
	// Design for headers
	/*
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
	*/
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// The problem appears to be here. Leaving the song picker resets request to nil
		if request == nil {
			request = Request()
		}
		
		nameTextField.placeholder = namePlaceholder
		songTextView.reset(with: songPlaceholder)
		notesTextView.reset(with: notesPlaceHolder)
		
		// If a song has been selected from browser, put it in the text field.
		if let song = request?.songObject {
			pr(song)
			songTextView.text = song.title + "\nby " + song.artist.name
			songTextView.textColor = UIColor.black
		}
	}
	
	// MARK: Submitting the request
	
	@IBAction func submitButtonPressed(_ sender: UIButton) {
		
		nameTextField.endEditing(true)
		songTextView.endEditing(true)
		notesTextView.endEditing(true)
		
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
					alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in self.clearRequest() })
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
			                              message: "Could not write to the Realm.",
			                              preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return
		}
	}
	
	func clearRequest () {
		nameTextField.text = nil
		nameTextField.placeholder = namePlaceholder
		songTextView.reset(with: songPlaceholder)
		notesTextView.reset(with: notesPlaceHolder)
		request = Request()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Problem is
		if let songsVC = segue.destination.childViewControllers.first as? SongsTableViewController {
			songsVC.realmConfiguration = globalConfig
			songsVC.currentRequest = request
		}
	}	
}
