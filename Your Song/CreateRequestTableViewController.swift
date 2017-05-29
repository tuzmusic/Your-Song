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
		get { return YPB.realmSynced }
		set { YPB.realmSynced = newValue }
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
	
	// MARK: Controller - loading the request/populating textViews
	
	override func viewWillAppear(_ animated: Bool) {
		if let request = self.request {
			textViewInfo.keys.forEach {
				$0.text = request.value(forKey: textViewInfo[$0]!.keyPath) as! String
				if $0.text.isEmpty {
					$0.reset(with: textViewInfo[$0]!.placeholder, color: placeholderColor)
				}
			}
		} else {
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
	
	// MARK: Text field/view outlets and delegate methods
	
	var textViewInfo: [UITextView : (placeholder: String, keyPath: String)] {
		return [nameTextView : (TextViewStrings.placeholders.user, "userString"),
		        songTextView : (TextViewStrings.placeholders.song, "songString"),
		        notesTextView : (TextViewStrings.placeholders.notes, "notes")]
	}
	
	struct TextViewStrings {
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
		
		do {
			if let realm = realm {
				try realm.write {
					realm.add(request)
				}
				func confirmSubmittedRequest() {
					var infoString = "Your Name: \(request.userString)" + "\r"
					infoString += "Your Song: \(request.songString.replacingOccurrences(of: "\n", with: " "))" + "\r"
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
		/* if let songsVC = segue.destination.childViewControllers.first as? SongsTableViewController{
		} */
	}
}
