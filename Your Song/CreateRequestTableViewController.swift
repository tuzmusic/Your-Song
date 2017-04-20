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
				message: "Could not write to the Realm.",
				preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// The problem appears to be here. Leaving the song picker resets request to nil
		if request == nil {
			request = Request()
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Problem is
		if let songsVC = segue.destination.childViewControllers.first as? SongsTableViewController {
			songsVC.realmConfiguration = globalConfig
			songsVC.currentRequest = request
		}
	}	
}
