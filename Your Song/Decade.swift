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
	
	var songs = LinkingObjects(fromType: Song.self, property: "decade")
	
	var artists: List<Artist> {
		var artists = Array<Artist>()
		for song in songs {
			if !artists.contains(song.artist) {
				artists.append(song.artist)
			}
		}
		artists.sort { $0.sortName < $1.sortName }
		//return List(artists)
		let x = List<Artist>()
		artists.forEach {
			x.append($0)
		}
		return x
	}
	
	static func decadeNames(for yearsList: String) -> [String] {
		let yearStrings = yearsList.components(separatedBy: Song.separator)
		var years = [String]()
		for year in yearStrings where !year.isEmpty {
			years.append(year)
		}
		var string = ""
		var decadeStrings = [String]()
		for year in years {
			if let year = Int(year) {
				switch year {
				case 0..<10: string = "'\(year)0s"
				case 10: string = "'10s"
				case 1900...3000: string = "'" + String(((year - (year<2000 ? 1900 : 2000)) / 10)) + "0s"
				default: string = "Unknown Decade"
				}
				decadeStrings.append(string)
			}
			else {
				decadeStrings.append(year)
			}
		}
		return decadeStrings
	}
}
