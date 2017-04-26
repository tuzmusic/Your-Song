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
	dynamic var user: YpbUser?
	dynamic var userString: String = ""
	dynamic var songString: String = ""
	dynamic var songObject: Song?
	dynamic var notes: String = ""
	dynamic var date = Date()
	var tip: Double?
	dynamic var played = false
	dynamic var singAtMic = false
	dynamic var event: Event?
	
}


final class Event: Object {
	dynamic var name: String = "General"
	dynamic var date: Date?
	var type: EventType?
	
	enum EventType {
		case pianoBar
		case weddingNoTip
		case openMic
	}
}
