//
//  RequestCell.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 5/31/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

class RequestTableViewCell: UITableViewCell {

	var request = Request! {
		didSet {
			updateUI()
		}
	}
	
	@IBOutlet weak var userDateLabel: UILabel!
	@IBOutlet weak var tipLabel: UILabel!
	@IBOutlet weak var songTitleLabel: UILabel!
	@IBOutlet weak var artistLabel: UILabel!
	@IBOutlet weak var notesLabel: UILabel!

	func timeSince(time: Date) -> String {
		
		let hoursAgo = DateInterval(start: date, end: Date()).duration / hour
		let minutesAgo = hoursAgo * 60
		let timeAgo = "\(Int(minutesAgo / 60))h \(Int(minutesAgo.truncatingRemainder(dividingBy: 60)))m ago"
		
		return timeAgo
	}
	
	func updateUI() {
		var userName = "\(request.user.firstName) \(request.user.lastName)"
		if !request.userString.isEmpty {
			userName = "\(request.userString) (\(userName))"
		}
		userDateLabel.text = "\(userName) - \(timeSince(time: request.date))"
		songTitleLabel.text = request.songObject.title ?? request.songString
		artistLabel.text = request.songObject.artist ?? nil
		notesLabel.text = request.notes
		tipLabel.text = "$\(request.tip)" ?? nil
	}
	
	@IBAction func markComplete(_ sender: UIButton) {
		request.played = true
		sender.titleLabel?.textColor = UIColor.green
	}
	
	@IBAction func copyAndOpenApp(_ sender: UIButton) {
		
	
	}


}
