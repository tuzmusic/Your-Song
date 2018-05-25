//
//  MenuTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/13/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

protocol RealmDelegate: class {
	var realm: Realm? { get set }
}

class MasterViewController: UITableViewController {
	
	@IBOutlet weak var signedInLabel: UILabel!
	
	override func viewWillAppear(_ animated: Bool) {
		guard let user = YpbUser.current else { return }
		signedInLabel.text = "Signed in as \(user.fullName) (\(user.email))"
		super.viewWillAppear(true)
	}
	weak var navDelegate: UINavigationController?
	
	@IBAction func logOutTapped(_ sender: Any) {
		if let navDelegate = navDelegate {
			if let first = navDelegate.viewControllers.first {
				if let loginDelegate = first as? SignInTableViewController {
					loginDelegate.logOutAll()
					navDelegate.popToRootViewController(animated: true)
					splitViewController?.showDetailViewController(loginDelegate, sender: nil)
				}
			}
		}
	}
}
