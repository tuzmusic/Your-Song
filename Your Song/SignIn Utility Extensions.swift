//
//  SignIn Utility Extensions.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 2/4/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

extension SignInTableViewController {
	
	// MARK: Utility functions
    
    func configureJonathanSubscription() {
        let songs = realm?.objects(Song.self)
        let subscription = songs?.subscribe()
//        let subscriptionToken = subscription?.observe(\.state, options: .initial) { state in
//            if state == .complete {
//                // here you might remove any activity spinner
//            }
//        }
    }
	
	func toggleRealmButtons (signedIn: Bool) {
		realmLoginButtons[0].isEnabled = signedIn ? false : true
		realmLoginButtons[1].isEnabled = signedIn ? false : true
		realmLoginButtons[2].isEnabled = signedIn ? true : false
	}
	
	func presentInvalidEmailAlert () {
		let alert = UIAlertController(title: "Invalid email", message: "Please enter a valid email address.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	fileprivate func importSongs() {
		if let realm = realm {
			let deleteAll = false
			if deleteAll {
				try! realm.write { realm.deleteAll() }
			}
			SongImporter.importSongsTo(realm: realm)
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 1 {
			switch indexPath.row {
			case 0: YPB.deleteDuplicateSongs(in: realm!)
			case 1: YPB.deleteDuplicateCategories(in: realm!)
			case 2: YPB.populateNilArtists(in: realm!)
//			case 3: importSongs()				
			default: break
			}
		}
	}
	
	func setPermissions() {
		if let user = SyncUser.current {
			// let path = RealmConstants.realmAddress.absoluteString//.replacingOccurrences(of: ":9080", with: "")
			let permission = SyncPermission(realmPath: "*", identity: "*", accessLevel: .write)
			user.apply(permission) { (error) in
				if let error = error {
					pr(error)
				} else {
					pr("Permission change succeeded?")
				}
			}
		}
	}
	
	func getPermissions() {
		SyncUser.current?.retrievePermissions { (results, error) in
			if let results = results {
				pr(results.description)
			} else if let error = error {
				pr(error)
			}
		}
	}
}
