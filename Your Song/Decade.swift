//
//  Decade.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/8/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Decade: BrowserCategory {
	
	let songs = LinkingObjects(fromType: Song.self, property: "decade")
	
	var artists: [Artist] {
		var artists = [Artist]()
		self.songs.forEach {
			if !artists.contains($0.artist!) {
				artists.append(($0.artist!))
			}
		}
		return artists
	}
	
	static func decadeNames(for yearsList: String) -> [String] {
		let yearStrings = yearsList.components(separatedBy: Song.separator)
		var years = [Int]()
		for year in yearStrings {
			if !year.isEmpty, let year = Int(year) {
				years.append(year)
			}
		}
		var strings = [String]()
		for year in years {
			var string = ""
			switch year {
			case 0..<10: string = "'\(year)0s"
			case 10: string = "'10s"
			case 1900...3000: string = "'" + String(((year - (year<2000 ? 1900 : 2000)) / 10)) + "0s"
			default: "Unknown Decade"
			}
			strings.append(string)
		}
		return strings
	}
}
