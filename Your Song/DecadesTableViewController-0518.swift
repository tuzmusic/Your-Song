//
//  DecadesTableViewController-0518.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 6/5/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class DecadesTableViewController_0518: BrowserTableViewController_0518 {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.type = Decade.self
		self.extraRows = ["All Songs", "All Artists"]
	}
}
