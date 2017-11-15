//
//  Realm Object Classes.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/19/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Request: Object {
	@objc dynamic var user: YpbUser?
	@objc dynamic var userString: String = ""
	@objc dynamic var songString: String = ""
	@objc dynamic var songObject: Song?
	@objc dynamic var notes: String = ""
	@objc dynamic var date = Date()
	var tip: Double?
	@objc dynamic var played = false
	@objc dynamic var event: Event?

	// Implement later
	@objc dynamic var singAtMic = false

}

final class Event: Object {
	@objc dynamic var name: String = "General"
	@objc dynamic var date: Date?
	var type: EventType?
	
	enum EventType {
		case pianoBar
		case weddingNoTip
		case openMic
	}
}
