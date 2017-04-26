//
//  YpbUser.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/25/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class YpbUser: Object {
	dynamic var id: String = ""
	dynamic var firstName: String = ""
	dynamic var lastName: String = ""
	dynamic var registeredDate = Date()
	dynamic var email: String = ""
	let requests = LinkingObjects(fromType: Request.self, property: "user")
	
	func averageTip() -> Double {
		let average = 0.0
		
		
		
		return average
	}
	
	class func user(firstName: String, lastName: String, email: String, in realm: Realm) -> YpbUser? {
		if let existingUser = realm.objects(YpbUser.self)
			.filter("email =[c] %@", email).first
		{
			return existingUser
		} else {
			let user = YpbUser()
			user.firstName = firstName
			user.lastName = lastName
			user.email = email
			try! realm.write {
				realm.add(user)
			}
			return user
		}
	}
	
}
