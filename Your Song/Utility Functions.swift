//
//  Utility Functions.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/27/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift
import RealmSearchViewController

extension YPB {
	
	class func createBloggerBlogFromSongCatalog() {
		
	}
	
	class func writeSongCatalogToTxtFile () {
		
		/*
		func precedeSecondArtistWithComma() {
			for song in YPB.realmLocal.objects(Song.self) {
				var components = song.songDescription.components(separatedBy: " - ")
				if components.count > 2 {
					var newDescription = components[0] + " - " + components[1]
					for i in 2 ..< components.count {
						newDescription += ", " + components[i]
					}
					try! YPB.realmLocal.write {
						song.songDescription = newDescription
					}
				}
			}
		} */
		
		// Assemble the text
		var text = ""
		
		let decades = YPB.realmLocal.objects(Decade.self)
		
		for decade in decades {
			var songsArray = [Song]()
			for song in decade.songs {
				songsArray.append(song)
			}
			songsArray.sort { $0.songDescription < $1.songDescription }
			text += "\n" + decade.name + "\n"
			for song in songsArray {
				text += song.songDescription + " / "
			}
		}
		
		let fileName = "songCatalog.txt" //this is the file. we will write to and read from it
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let path = dir.appendingPathComponent(fileName)
			do {
				try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
			}
			catch {
				print("Couldn't write file")
			}
		}
	}
}



