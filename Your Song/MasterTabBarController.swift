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
	
	//var importer = SongImporter()
	var fileName: String! = "song list 1"
	var songs = [Song]()
	var headers = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//songs = importer.getSongsFromFile(named: fileName)
		if let songs = getSongsFromOnlineRealm() {
			for vc in self.viewControllers! {
				if let browser = vc as? BrowserTableViewController {
					browser.songs = songs
				}
			}
		}
	}
	
	func getSongsFromOnlineRealm() -> [Song]? {
		
		var songsOnlineRealm: Realm?
		func setupOnlineRealm() {
			let username = "tuzmusic@gmail.com"
			let password = "***REMOVED***"
			let localHTTP = URL(string:"http://54.208.237.32:9080")!
			
			SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
				
				// Log in the user
				user, error in
				guard let user = user else {
					print(String(describing: error!)); return }
				print("Initial login successful")
				
				DispatchQueue.main.async {
					// Open the online Realm
					let realmAddress = URL(string:"realm://54.208.237.32:9080/~/yourPianoBarSongs/JonathanTuzman/")!
					let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
					let configuration = Realm.Configuration(syncConfiguration: syncConfig)
					
					do {
						songsOnlineRealm = try Realm(configuration: configuration)
					} catch {
						print(error)
					}
				}
			}
		}
		
		setupOnlineRealm()
		
		if let onlineSongs = songsOnlineRealm?.objects(Song.self) {
			return Array(onlineSongs).sorted
				{ $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending }
		}
		return nil
	}
}
