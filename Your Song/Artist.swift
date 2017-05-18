//
//  Artist.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Artist: BrowserCategory {
	var songs = LinkingObjects(fromType: Song.self, property: className().lowercased())
}

