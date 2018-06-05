//
//  ArtistsTableViewController-0518.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/31/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class ArtistsTableViewController_0518: BrowserTableViewController_0518 {
	override func viewDidLoad() {
		super.viewDidLoad()
		self.type = Artist.self
		self.extraRows = ["All Songs"]
	}
	
}
