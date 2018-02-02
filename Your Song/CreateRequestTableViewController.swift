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
	
	var placeholderColor: UIColor = UIColor.lightGray
	var fieldTextColor: UIColor = UIColor.black
	
	// MARK: MODEL
	
	var realm: Realm? {
		get {
			return YPB.realmSynced			
		} set {
			YPB.realmSynced = newValue
		}
	}
	
	var request: Request!
	
	var userString: String {
		get {
			return request.userString
		} set {
			request.userString = newValue
		}
	}
	
	var songObject: Song? {
		get {
			return request.songObject
		} set {
			if let song = newValue {
				songTextView.textColor = fieldTextColor
				songString = "\"\(song.title)\"" + "\n" + "by " + song.artist.name
				request.songObject = song
			}
		}
	}
	
	var songString: String {
		get {
			return request.songString
		} set {
			request.songString = newValue
		}
	}
	
	var notes: String {
		get {
			return request.notes
		} set {
			request.notes = newValue
		}
	}
	
	var spinner: UIActivityIndicatorView {
		let spinner = view.addNewSpinner()
		if let navcon = self.navigationController {
			spinner.frame.origin.y = navcon.view.frame.midY - 60
		}
		return spinner
		
	}

	// MARK: Controller - loading the request/populating textViews
		
	fileprivate func populateRequestFields() {
		if let request = self.request {		// If we're entering the view from the song picker, and there's already a request started
			textViewInfo.keys.forEach {
				$0.text = request.value(forKey: textViewInfo[$0]!.keyPath) as! String
				if $0.text.isEmpty {
					$0.reset(with: textViewInfo[$0]!.placeholder, color: placeholderColor)
				}
			}
		} else {	// If there's no request started
			request = Request()
			if let user = YPB.ypbUser {
				request.user = user
				request.userString = "\(user.firstName) \(user.lastName)"
			}
			textViewInfo.keys.forEach {
				if request.value(forKey: textViewInfo[$0]!.keyPath) as! String == "" {
					$0.reset(with: textViewInfo[$0]!.placeholder, color: placeholderColor)
				} else {
					$0.text = request.value(forKey: textViewInfo[$0]!.keyPath) as! String
				}
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		populateRequestFields()
	}
	
	// MARK: Text field/view outlets and delegate methods

	// TO-DO: I'm doing a lot of "active" placeholdering. There's probably a way to clear a text field/view to get the placeholder back.
	var textViewInfo: [UITextView : (placeholder: String, keyPath: String)] {
		return [nameTextView : (TextViewStrings.placeholders.user, "userString"),
			   songTextView : (TextViewStrings.placeholders.song, "songString"),
			   notesTextView : (TextViewStrings.placeholders.notes, "notes")]
	}
	
	struct TextViewStrings {
		struct placeholders {
			static let user = "Enter your name"
			static let song = "Enter your song, or look for your favorite song in our catalog"
			static let notes = "Have a dedication? Want to come up and sing? Put any extra notes here"
		}
	}
	
	@IBOutlet weak var nameTextView: UITextView!
	@IBOutlet weak var songTextView: UITextView!
	@IBOutlet weak var notesTextView: UITextView!
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == placeholderColor { textView.text = "" }
		textView.textColor = fieldTextColor
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		request?.setValue(textView.text, forKey: textViewInfo[textView]!.keyPath)
		if textView.text == "" {
			textView.reset(with: textViewInfo[textView]!.placeholder, color: placeholderColor)
			if textView == songTextView {
				songObject = nil
			}
		}
	}
	
	// MARK: Submitting the request
	
	@IBAction func submitButtonPressed(_ sender: UIButton) {
		
		textViewInfo.keys.forEach { $0.endEditing(true) }
		
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

		//spinner.startAnimating()
		
		do {
			if let realm = YPB.realmSynced {
				try realm.write {
					realm.add(request)
				}
				confirmSubmittedRequest(request)
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
		spinner.stopAnimating()
		spinner.removeFromSuperview()
	}
	
	@IBAction func addSampleRequest(_ sender: Any) {
		if !Request.addSampleRequest() {
			let alert = UIAlertController(title: "Can't add request", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true)
		}
	}
		
	func clearRequest () {
		for view in textViewInfo.keys {
			view.reset(with: textViewInfo[view]!.placeholder, color: placeholderColor)
		}
		request = Request()
	}
	
	func confirmSubmittedRequest(_ request: Request) {
		var infoString = """
		Your Name: \(request.userString)
		Your Song: \(request.songString.replacingOccurrences(of: "\n", with: " "))
		
		"""
		if !request.notes.isEmpty { infoString += "Your Notes: \(request.notes)" }
		let alert = UIAlertController(title: "Request Sent!", message: infoString, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in self.clearRequest() })
		present(alert, animated: true, completion: nil)
	}
		
}
