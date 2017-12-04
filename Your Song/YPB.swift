//
//  YPB.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class YPB {
	
	static var currentRequest: Request?
	
	static var realmSynced: Realm!
	static var realmLocal = try! Realm() {
		didSet {
			populateLocalRealmIfEmpty()
		}
	}
	
	class func populateLocalRealmIfEmpty() {
		if YPB.realmLocal.objects(Song.self).isEmpty {
			SongImporter().importSongsToLocalRealm()
		}
	}
	
	static var realm = realmLocal
	
	static var ypbUser: YpbUser!
	
	struct UserInfo {
		var firstName = ""
		var lastName = ""
		var email = ""
	}
	
	class func setupRealm() {
		
		struct RealmConstants {
			static let ec2ip = "54.205.63.24"
			static let ec2ipDash = ec2ip.replacingOccurrences(of: ".", with: "-")
			static let amazonAddress = "ec2-\(ec2ipDash).compute-1.amazonaws.com:9080"
			static let localHTTP = URL(string:"http://" + ec2ip)!
			static let publicDNS = URL(string:"http://" + amazonAddress)!
			static let realmAddress = URL(string:"realm://" + amazonAddress + "/YourPianoBar/JonathanTuzman/")!
			
			static let userCred = SyncCredentials.usernamePassword(
				username: "realm-admin", password: "")
		}
	
		SyncUser.logIn(with: RealmConstants.userCred, server: RealmConstants.publicDNS) {
			
			// Log in the user. If not, use local Realm config. If unable, return nil.
			user, error in
			guard let user = user else {
				print("Could not access server. Using local Realm [default configuration]. Error:")
				print(error!)
				populateLocalRealmIfEmpty()
				return
			} // guard else
			
			DispatchQueue.main.async {
				
				// Open the online Realm
				let syncConfig = SyncConfiguration (user: user, realmURL: RealmConstants.realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				
				YPB.realmSynced = try! Realm(configuration: configuration)
				YPB.realm = realmSynced
				let realmSet = NSNotification.Name("realm set")
				NotificationCenter.default.post(name: realmSet, object: nil)
				manageRealmContents()				
				
			}
		}
	}
	
	class func manageRealmContents() {
		if YPB.realmLocal.objects(Song.self).isEmpty {
			if !YPB.realmSynced.objects(Song.self).isEmpty {
				YPB.populateLocalRealmFromSyncedRealm()
			} else {
				SongImporter().importSongsToLocalRealm()
				YPB.populateSyncedRealmFromLocalRealm()
			}
		} else {
			// Local realm is all good, so do nothing.
			// TO-DO: Note that this will never UPDATE a non-empty realm!
		}
		YPB.deleteDuplicateCategories(in: YPB.realm)
	}
	
	class func populateLocalRealmFromSyncedRealm() {
		let onlineSongs = YPB.realmSynced.objects(Song.self)
		for song in onlineSongs {
			try! YPB.realmLocal.write {
				_ = Song.createSong(fromObject: song, in: YPB.realmLocal)
			}
		}
	}
	
	class func populateSyncedRealmFromLocalRealm() {
		for song in YPB.realmLocal.objects(Song.self) {
			try! YPB.realmSynced.write {
				_ = Song.createSong(fromObject: song, in: YPB.realmSynced)
			}
		}
	}
	
	class func emptyLocalRealm() {
		try! YPB.realmLocal.write {
			YPB.realmLocal.deleteAll()
		}
	}	
}

// Including this here because it's not finding the class in its own file for some reason.
class SongImporter {
	
	typealias SongData = [String]
	
	func importSongsToLocalRealm() {
		let fileName = "song list"
		if let songData = songData(fromTSV: fileName) {
			createSongsInLocalRealm(songData: songData)
		}
	}
	
	func songData (fromTSV fileName: String) -> [SongData]? {
		
		var songData = [[String]]()
		
		if let path = Bundle.main.path(forResource: fileName, ofType: "tsv") {
			if let fullList = try? String(contentsOf: URL(fileURLWithPath: path)) {
				let songList = fullList
					.replacingOccurrences(of: "\r", with: "")
					.components(separatedBy: "\n")
				guard songList.count > 1 else { print("Song list cannot be used: no headers, or no listings!")
					return nil }
				for song in songList {
					songData.append(song.components(separatedBy: "\t"))
				}
			}
		}
		return songData
	}
	
	
	func createSongsInLocalRealm(songData: [SongData]) {
		
		// Get the headers from the first entry in the database
		guard let headers = songData.first?.map({$0.lowercased()}) else {
			print("Song list is empty, could not extract headers.")
			return
		}
		
		YPB.realmLocal.beginWrite()
		
		for songComponents in songData where songComponents.map({$0.lowercased()}) != headers {
			if let indices = headerIndices(from: headers) {
				if let appIndex = headers.index(of: "app"), songComponents[appIndex] != "Y" {
					continue
				}
				_ = Song.createSong(fromComponents: songComponents, with: indices, in: YPB.realmLocal)
			}
		}
		
		try! YPB.realmLocal.commitWrite()
	}
	
	func headerIndices(from headers: [String]) -> (title: Int, artist: Int?, genre: Int?, year: Int?)? {
		struct SongHeaderTags {
			static let titleOptions = ["song", "title", "name"]
			static let artist = "artist"
			static let genre = "genre"
			static let year = "year"
		}
		
		guard let titleHeader = headers.first(where: { SongHeaderTags.titleOptions.contains($0) }) else {
			print("Songs could not be created: Title field could not be found.")
			return nil
		}
		let titleIndex = headers.index(of: titleHeader)!
		let artistIndex = headers.index(of: SongHeaderTags.artist)
		let genreIndex = headers.index(of: SongHeaderTags.genre)
		let yearIndex = headers.index(of: SongHeaderTags.year)
		return (titleIndex, artistIndex, genreIndex, yearIndex)
	}
	
}

