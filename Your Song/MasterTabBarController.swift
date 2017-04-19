//
//  MasterTabBarController.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

class MasterTabBarController: UITabBarController {

	override func viewDidLoad() {
		super.viewDidLoad()
		for vc in self.viewControllers! {
			(vc as? UITableViewController)?.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length, 0)
		}
	}
}
