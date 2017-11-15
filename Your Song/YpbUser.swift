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
	@objc dynamic var id: String = ""
	@objc dynamic var firstName: String = ""
	@objc dynamic var lastName: String = ""
	@objc dynamic var registeredDate = Date()
	@objc dynamic var email: String = ""
	let requests = LinkingObjects(fromType: Request.self, property: "user")
	
	var tips: [Double] {
		var tips = [Double]()
		for request in requests where request.tip != nil {
			tips.append(request.tip!)
		}
		return tips
	}
	
	var averageTip: Double {
		return tips.reduce(0, { $0 + $1 }) / Double(tips.count)
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
