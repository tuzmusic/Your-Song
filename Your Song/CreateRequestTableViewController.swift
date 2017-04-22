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
	func reset(with placeholder: String, color: UIColor) {
		self.text = placeholder
		self.textColor = color
	}
}

class CreateRequestTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
	
	var placeholderColor: UIColor = ypbOrange
	
	// MARK: Request model
	var realm: Realm? {
		get { return YpbApp.ypbRealm }
		set { YpbApp.ypbRealm = newValue }
	}
	
	var request: Request? {
		didSet {
			pr("request set")
		}
	}
	
	// MARK: Text field/view outlets and delegate methods
	
	var textViewInfo: [UITextView : (placeholder: String, keyPath: String)] {
		return [nameTextView : (TextViewStrings.placeholders.user, TextViewStrings.keypaths.user),
		        songTextView : (TextViewStrings.placeholders.song, TextViewStrings.keypaths.song),
		        notesTextView : (TextViewStrings.placeholders.notes, TextViewStrings.keypaths.notes)]
	}
	
	struct TextViewStrings {
		struct keypaths {
			static let user = "userString"
			static let song = "songString"
			static let notes = "notes"
		}
		struct placeholders {
			static let user = "Enter your name"
			static let song = "Enter your song, or look for your favorite song in our catalog"
			static let notes = "Got a dedication? Want to come up and sing? Put any extra notes here"
		}
	}
	
	@IBOutlet weak var nameTextView: UITextView!
	@IBOutlet weak var songTextView: UITextView!
	@IBOutlet weak var notesTextView: UITextView!
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == placeholderColor { textView.text = "" }
		textView.textColor = UIColor.black
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text == "" {
			textView.reset(with: textViewInfo[textView]!.placeholder, color: placeholderColor)
		} else {
			request?.setValue(textView.text, forKey: textViewInfo[textView]!.keyPath)
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
	
	override func viewWillAppear(_ animated: Bool) {
		
		if let currentRequest = request {
			if let song = currentRequest.songObject {
				songTextView.text = song.title + "\n" + "by " + song.artist.name
				songTextView.textColor = UIColor.black
			}
		} else {
			clearRequest()
		}
		
		// Clearing of the request (unless there's already a request) (or something) - previous implementation 
		/*
		// This can probably be moved to somewhere in the optional binding.
		if request == nil {
			request = Request()
		}
		
		for view in textViewInfo.keys where view != songTextView {
			view.reset(with: textViewInfo[view]!.placeholder, color: placeholderColor)
		}
		
		// If a song has been selected from browser, put it in the text field.
		if let song = request?.songObject {
			pr(song)
			songTextView.text = song.title + "\nby " + song.artist.name
			songTextView.textColor = UIColor.black
		} else {
			songTextView.reset(with: TextViewStrings.placeholders.song, color: placeholderColor)
		} */
	}
	
	// MARK: Submitting the request
	
	@IBAction func submitButtonPressed(_ sender: UIButton) {
		
		textViewInfo.keys.forEach { $0.endEditing(true) }
//		nameTextView.endEditing(true)
//		songTextView.endEditing(true)
//		notesTextView.endEditing(true)
		
		guard let request = request, !request.userString.isEmpty && !request.songString.isEmpty else {
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
					if !request.notes.isEmpty { infoString += "Your Notes: \(request.notes)" }
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
		for view in textViewInfo.keys {
			view.reset(with: textViewInfo[view]!.placeholder, color: placeholderColor)
		}
		request = Request()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		for view in [nameTextView, songTextView, notesTextView] as [UIView] {
			view.resignFirstResponder()
		}
		if let songsVC = segue.destination.childViewControllers.first as? SongsTableViewController
		{
			//songsVC.realmConfiguration = YpbApp.ypbRealm.configuration
			songsVC.realmConfiguration = Realm.Configuration.defaultConfiguration
		}
	}
}
